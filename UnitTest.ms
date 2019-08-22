/*! © 2015 imaoki | MIT License | https://github.com/imaoki */
/**
ユニットテストを行うためのサポート機能を提供する。
*/
struct UnitTest (
  /** @prop <DotNetObject:System.String> 水平線を生成するためお空文字列オブジェクト。 */
  private blankString = DotNetObject "System.String" "",

  /** @prop <DotNetClass:System.DateTime> */
  private dateTimeClass = DotNetClass "System.DateTime",
  /** @prop <DotNetClass:System.IO.Directory> */
  private directoryClass = DotNetClass "System.IO.Directory",
  /** @prop <DotNetClass:System.IO.File> */
  private fileClass = DotNetClass "System.IO.File",
  /** @prop <DotNetClass:System.IO.Path> */
  private pathClass = DotNetClass "System.IO.Path",
  /** @prop <DotNetClass:System.Text.RegularExpressions.Regex> */
  private regexClass = DotNetClass "System.Text.RegularExpressions.Regex",
  /** @prop <DotNetObject:System.Type> */
  private typeOfEncoding = (DotNetClass "System.Type").GetType "System.Text.Encoding",
  /** @prop <DotNetObject:System.Text.UTF8Encoding> */
  private utf8withoutBOM = DotNetObject "System.Text.UTF8Encoding" false,

  /**
  全てのディレクトリとサブディレクトリを作成する。
  @param path <String>
  @return <OkClass>
  */
  public fn CreateDirectory path = (
    if not this.DirectoryExists path do (
      this.directoryClass.CreateDirectory path
    )
    ok
  ),

  /**
  ディレクトリを削除する。
  @param path <String>
  @param recursive: <BooleanClass> サブディレクトリ、ファイルを削除する場合は`true`、それ以外の場合は`false`。既定値は`true`。
  @return <OkClass>
  */
  public fn DeleteDirectory path recursive:true = (
    if recursive then (
      this.directoryClass.Delete path recursive
    )
    else (
      this.directoryClass.Delete path
    )
    ok
  ),

  /**
  ファイルを削除する。
  @param path <String>
  @return <OkClass>
  */
  public fn DeleteFile path = (
    this.fileClass.Delete path
    ok
  ),

  /**
  パスが既存のディレクトリを参照しているかどうかを確認する。
  @param path <String>
  @return <BooleanClass>
  */
  public fn DirectoryExists path = (
    this.directoryClass.Exists path
  ),

  /**
  パスが既存のファイルを参照しているかどうかを確認する。
  @param path <String>
  @return <BooleanClass>
  */
  public fn FileExists path = (
    this.fileClass.Exists path
  ),

  /**
  パス文字列のディレクトリパスを取得する。
  @param path <String>
  @return <String>
  */
  public fn GetDirectoryName path = (
    this.pathClass.GetDirectoryName path
  ),

  /**
  パス文字列の絶対パスを取得する。
  @param path <String>
  @return <String>
  */
  public fn GetFullPath path = (
    this.pathClass.GetFullPath path
  ),

  /**
  ファイルを評価する。
  @param path <String>
  @return <Any>
  @remark `fileIn`の結果を直接変数に代入すると正常に評価されない場合があるため、テスト内でファイルを評価する際はこのメソッドを使用する。
  */
  public fn Import path = (
    fileIn path
  ),

  /**
  `::test`が持つテストメソッドを呼び出す。
  @return <OkClass>
  @remark 通常は`::test`の`SetupStruct`メソッド内で呼び出すが、非同期に処理する必要がある場合はイベントハンドラ等のメソッドから呼び出す。
  */
  public fn InvokeTest = (
    if this.IsValidTest ::test do (
      local methodNames = this.collectTestMethodNames()
      for methodName in methodNames do (
          ::test.Setup()
          execute ("::test." + methodName + "()")
          ::test.Teardown()
      )
      ::test.TeardownStruct()
    )
    format "UnitTest % done\n" (this.nowTime())
    ok
  ),

  /**
  テストオブジェクトの有効性を判定する。
  @param obj <Any>
  @return <BooleanClass>
  */
  public fn IsValidTest obj = (
    isStruct obj \
        and isProperty obj #CurrentDir \
        and isProperty obj #CurrentFile \
        and isProperty obj #ParentDir \
        and isProperty obj #Setup \
        and isProperty obj #SetupStruct \
        and isProperty obj #Teardown \
        and isProperty obj #TeardownStruct
  ),

  /**
  水平線を出力する。
  @param digit: <Integer> 水平線の桁数。既定値は`80`。
  @param separator: <String> 水平線に使用する文字。既定値は`"-"`。
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @return <OkClass>
  */
  public fn PrintHR digit:80 separator:"-" indent:"" out:listener = (
    local hr = this.blankString.PadLeft digit separator
    format "%%\n" indent hr to:out
    ok
  ),

  /**
  テキストファイルの内容を取得する。
  @param path <String>
  @param encoding: <DotNetObject:System.Text.Encoding> エンコーディングオブジェクト。既定値はBOM無しUTF-8。
  @return <String>
  @remark 改行コードは全てLFに変換される。
  */
  public fn ReadText path encoding: = (
    local content = ""
    if this.FileExists path do (
      if not this.isEncodingObject encoding do (
        encoding = this.utf8withoutBOM
      )
      content = replace_crlf_with_lf (this.fileClass.ReadAllText path encoding)
    )
    content
  ),

  /**
  テストを開始する。
  @param obj <Struct:TestStruct>
  @return <OkClass>
  */
  public fn Run obj = (
    if isStruct obj do (
      ::test = obj
    )
    if this.IsValidTest ::test do (
      format "UnitTest % start @\"%\"\n" (this.nowTime()) ::test.CurrentFile
      ::test.SetupStruct()
    )
    ok
  ),

  /**
  ファイルを作成して文字列を書き込む。
  @param path <String>
  @param content <String>
  @param encoding: <DotNetObject:System.Text.Encoding> エンコーディングオブジェクト。既定値はBOM無しUTF-8。
  @return <OkClass>
  */
  public fn WriteText path content encoding: = (
    if not this.isEncodingObject encoding do (
      encoding = this.utf8withoutBOM
    )
    this.fileClass.WriteAllText path content encoding
    ok
  ),

  /**
  `::test`に実装された公開テストメソッドの名前を収集する。
  @return <Array<String>>
  @remark 昇順にソートされる。
  */
  private fn collectTestMethodNames = (
    local propNames = getPropNames ::test
    sort propNames
    for propName in propNames collect (
      propName = toLower (propName as String)
      local propValue = undefined
      if this.regexClass.IsMatch propName "^test\d+.*" do (
        propValue = getProperty ::test propName
      )
      if classOf propValue == MAXScriptFunction then (
        propName
      )
      else (
        dontCollect
      )
    )
  ),

  /**
  指定オブジェクトが文字エンコーディングオブジェクトかどうかを判断する。
  @param obj <Any>
  @return <BooleanClass>
  */
  private fn isEncodingObject obj = (
    classOf obj == DotNetObject \
        and (obj.GetType()).IsSubclassOf this.typeOfEncoding
  ),

  /**
  現在時刻を取得する。
  @return <String>
  */
  private fn nowTime = (
    this.dateTimeClass.Now.ToString "yyyy/MM/dd HH:mm:ss"
  ),

  on Create do ()
)
