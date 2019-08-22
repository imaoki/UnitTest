/*! © 2015 imaoki | MIT License | https://github.com/imaoki */

global testCounter

struct TestStruct (
  public CurrentDir,
  public CurrentFile,
  public ParentDir,

  public UnitTestObj,

  private actual,
  private expected,
  -- private testDef,
  -- private testObj,

  public fn Setup = (
    ::testCounter.Setup += 1
    ok
  ),

  public fn SetupStruct = (
    -- this.testDef = ::unitTest.Import (this.ParentDir + @"\.ms")
    -- this.testObj = this.testDef()

    -- ::unitTest.InvokeTest()
    ::testCounter = DataPair Setup:0 Teardown:0

    this.actual = classOf ::testCounter
    this.expected = DataPair
    assert (this.actual == this.expected)

    this.actual = ::testCounter.Setup
    this.expected = 0
    assert (this.actual == this.expected)

    this.actual = ::testCounter.Teardown
    this.expected = 0
    assert (this.actual == this.expected)
    ok
  ),

  public fn Teardown = (
    ::testCounter.Teardown += 1
    ok
  ),

  public fn TeardownStruct = (
    -- this.testObj.Dump()

    this.actual = classOf ::testCounter
    this.expected = DataPair
    assert (this.actual == this.expected)

    this.actual = ::testCounter.Setup
    this.expected = 2
    assert (this.actual == this.expected)

    this.actual = ::testCounter.Teardown
    this.expected = 2
    assert (this.actual == this.expected)
    ok
  ),

  public fn Test01 = (
    -- this.actual = ::TestValue (undefined)
    -- this.expected = ::TestValue undefined
    -- assert (this.actual.Equals this.expected == true)

    this.actual = ::testCounter.Setup
    this.expected = 1
    assert (this.actual == this.expected)

    this.actual = ::testCounter.Teardown
    this.expected = 0
    assert (this.actual == this.expected)
    ok
  ),

  public fn Test02 = (
    this.actual = ::testCounter.Setup
    this.expected = 2
    assert (this.actual == this.expected)

    this.actual = ::testCounter.Teardown
    this.expected = 1
    assert (this.actual == this.expected)
    ok
  ),

  on Create do (
    this.CurrentFile = this.UnitTestObj.GetFullPath (getSourceFileName())
    this.CurrentDir = this.UnitTestObj.GetDirectoryName this.CurrentFile
    this.ParentDir = this.UnitTestObj.GetDirectoryName this.CurrentDir
  )
)

-- ::unitTest.Run (::TestStruct())

struct InvalidTestStruct (
  public CurrentDir,

  public fn Setup = (
    ok
  ),

  public fn Test01 = (
    ok
  ),

  on Create do ()
)

(
  -- clearListener()

  fn nowTime = (
    (DotNetClass "System.DateTime").Now.ToString "yyyy/MM/dd HH:mm:ss"
  )
  format "% start @\"%\"\n" (nowTime()) (getSourceFileName())

  local pathClass = DotNetClass "System.IO.Path"

  local currentDir = pathClass.GetDirectoryName (getSourceFileName())
  local parentDir = pathClass.GetDirectoryName currentDir

  local actual
  local expected
  local testDef
  local testObj

  local dataDir = currentDir + @"\Data"

  local pathA = dataDir + @"\A"
  local pathAB = dataDir + @"\A\B"
  local pathAC = dataDir + @"\A\C"

  local pathWrite = dataDir + @"\write.txt"

  local pathFloat = dataDir + @"\float.ms"
  local pathInteger = dataDir + @"\integer.ms"
  local pathString = dataDir + @"\string.ms"

  local directoryClass = DotNetClass "System.IO.Directory"
  local fileClass = DotNetClass "System.IO.File"

  testDef = fileIn (parentDir + @"\UnitTest.ms")
  testObj = testDef()

  -- ディレクトリパスの取得
  actual = testObj.GetDirectoryName pathFloat
  expected = dataDir
  assert (actual == expected)

  -- 絶対パスの取得
  actual = testObj.GetFullPath pathFloat
  expected = pathFloat
  assert (actual == expected)
  actual = testObj.GetFullPath "a.ms"
  expected = SymbolicPaths.GetPathValue "$max" + @"\a.ms"
  assert (actual == expected)

  -- 新規ディレクトリを作成
  actual = testObj.CreateDirectory pathAB
  expected = ok
  assert (actual == expected)
  assert (directoryClass.Exists pathAB == true)

  -- サブディレクトリを作成
  actual = testObj.CreateDirectory pathAC
  expected = ok
  assert (actual == expected)
  assert (directoryClass.Exists pathAC == true)

  -- ディレクトリの存在確認
  actual = testObj.DirectoryExists pathA
  expected = true
  assert (actual == expected)
  actual = testObj.DirectoryExists pathAB
  assert (actual == expected)
  actual = testObj.DirectoryExists pathAC
  assert (actual == expected)

  -- サブディレクトリを削除
  actual = testObj.DeleteDirectory pathAC
  expected = ok
  assert (actual == expected)
  assert (directoryClass.Exists pathAC == false)

  -- 親ディレクトリを削除
  actual = testObj.DeleteDirectory pathA
  expected = ok
  assert (actual == expected)
  assert (directoryClass.Exists pathA == false)
  assert (directoryClass.Exists pathAB == false)

  -- ファイルの作成
  actual = testObj.WriteText pathWrite "true"
  expected = ok
  assert (actual == expected)
  assert (fileClass.Exists pathWrite == true)

  -- ファイルの存在確認
  actual = testObj.FileExists pathWrite
  expected = true
  assert (actual == expected)

  -- ファイルの読み取り
  actual = testObj.ReadText pathWrite
  expected = "true"
  assert (actual == expected)

  -- ファイルの削除
  actual = testObj.DeleteFile pathWrite
  expected = ok
  assert (actual == expected)
  assert (fileClass.Exists pathWrite == false)

  -- ファイルの評価
  actual = testObj.Import pathFloat
  expected = 0.0
  assert (actual == expected)
  actual = testObj.Import pathInteger
  expected = 1
  assert (actual == expected)
  actual = testObj.Import pathString
  expected = "a"
  assert (actual == expected)

  -- 水平線の出力
  actual = testObj.PrintHR()
  expected = ok
  assert (actual == expected)

  -- テストオブジェクトの有効性を判定
  actual = testObj.IsValidTest (::InvalidTestStruct())
  expected = false
  assert (actual == expected)
  actual = testObj.IsValidTest (::TestStruct UnitTestObj:testObj)
  expected = true
  assert (actual == expected)

  -- テストを開始
  actual = testObj.Run (::TestStruct UnitTestObj:testObj)
  expected = ok
  assert (actual == expected)

  -- テストメソッドの呼び出し
  actual = testObj.InvokeTest()
  expected = ok
  assert (actual == expected)

  -- 水平線の出力
  actual = testObj.PrintHR()
  expected = ok
  assert (actual == expected)

  format "% done\n" (nowTime())
)
