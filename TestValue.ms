/*! © 2020 imaoki | MIT License | https://github.com/imaoki */
/**
テストで使用する値を格納する。
*/
struct TestValue (
  /** @prop <Any> */
  public Value,

  /** @prop <BooleanClass> 文字列の比較の際に大文字と小文字を区別しない場合は`true`、区別する場合は`false`。既定値は`false`。 */
  public IgnoreCase = false,

  /** @prop <DotNetClass:System.Text.RegularExpressions.Regex> */
  private regexClass = DotNetClass "System.Text.RegularExpressions.Regex",
  /** @prop <DotNetObject:System.Type> */
  private regexType,

  /**
  `Array`または`BitArray`の要素数が指定の数と等しいかどうかを判定する。
  @param count <Integer>
  @return <BooleanClass>
  */
  public fn CountEquals count = (
    local result = false
    case of (
      (this.IsArray()): result = this.Value.Count == count
      (this.IsBitArray()): result = this.Value.NumberSet == count
      default: ()
    )
    result
  ),

  /**
  `Array`または`BitArray`の要素数が指定の数以上かどうかを判定する。
  @param count <Integer>
  @return <BooleanClass>
  */
  public fn CountGreaterOrEquals count = (
    local result = false
    case of (
      (this.IsArray()): result = this.Value.Count >= count
      (this.IsBitArray()): result = this.Value.NumberSet >= count
      default: ()
    )
    result
  ),

  /**
  `Array`または`BitArray`の要素数が指定の数を超えるかどうかを判定する。
  @param count <Integer>
  @return <BooleanClass>
  */
  public fn CountGreaterThan count = (
    local result = false
    case of (
      (this.IsArray()): result = this.Value.Count > count
      (this.IsBitArray()): result = this.Value.NumberSet > count
      default: ()
    )
    result
  ),

  /**
  `Array`または`BitArray`の要素数が指定の数以下かどうかを判定する。
  @param count <Integer>
  @return <BooleanClass>
  */
  public fn CountLessOrEquals count = (
    local result = false
    case of (
      (this.IsArray()): result = this.Value.Count <= count
      (this.IsBitArray()): result = this.Value.NumberSet <= count
      default: ()
    )
    result
  ),

  /**
  `Array`または`BitArray`の要素数が指定の数未満かどうかを判定する。
  @param count <Integer>
  @return <BooleanClass>
  */
  public fn CountLessThan count = (
    local result = false
    case of (
      (this.IsArray()): result = this.Value.Count < count
      (this.IsBitArray()): result = this.Value.NumberSet < count
      default: ()
    )
    result
  ),

  /**
  指定したオブジェクトが現在のオブジェクトと等しいかどうかを判定する。
  @param obj <TestValue>
  @return <BooleanClass>
  @remark
  * 数値で構成される複合型は各要素の数値を`==`演算子ではなく`close_enough`関数を用いて比較する。

  * 配列や`DataPair`等の複合型は再帰的に比較する。

  * `Equals`メソッドを持っているオブジェクトは`Equals`メソッドを使用する。

  * 正規表現オブジェクトは`ToString`メソッドによるパターン文字列と`Options`プロパティをそれぞれ比較する。

  * プロパティアクセスによる`MAXScriptFunction`値の比較は失敗する。
    そのため関数値を比較する場合は一旦変数に格納し、その変数を用いてインスタンスを生成する。

    アサーション失敗
    : ```maxscript
      this.actual = ::TestValue this.method
      this.expected = ::TestValue this.method
      assert (this.actual.Equals this.expected == true)
      ```

    アサーション成功
    : ```maxscript
      local f = this.meshod
      this.actual = ::TestValue f
      this.expected = ::TestValue f
      assert (this.actual.Equals this.expected == true)
      ```

  * `DotNetMethod`の比較は常に`false`になる。
  */
  public fn Equals obj = (
    local isEquals = false
    if this.IsTestValue obj do (
      local testDef = classOf this
      isEquals = case of (
        (this.IsAngleAxis() and obj.IsAngleAxis()): (
          local t1 = testDef this.Value.Angle
          local t2 = testDef this.Value.Axis
          local t3 = testDef this.Value.NumRevs
          local o1 = testDef obj.Value.Angle
          local o2 = testDef obj.Value.Axis
          local o3 = testDef obj.Value.NumRevs
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsArrayOrArrayParameter() or obj.IsArrayOrArrayParameter()): (
          local result = obj.Value.Count == this.Value.Count
          for i = 1 to this.Value.Count while result do (
            local t1 = testDef this.Value[i]
            local o1 = testDef obj.Value[i]
            result = t1.Equals o1
          )
          result
        )
        (this.IsBigMatrix() and obj.IsBigMatrix()): (
          local result = obj.Value.Rows == this.Value.Rows \
              and obj.Value.Columns == this.Value.Columns
          for i = 1 to this.Value.Rows while result do (
            for j = 1 to this.Value.Columns while result do (
              local t1 = testDef this.Value[i][j]
              local o1 = testDef obj.Value[i][j]
              result = t1.Equals o1
            )
          )
          result
        )
        (this.IsBitArray() and obj.IsBitArray()): (
          this.Value.NumberSet == obj.Value.NumberSet \
              and (this.Value * obj.Value).NumberSet == this.Value.NumberSet
        )
        (this.IsBox2() and obj.IsBox2()): (
          local t1 = testDef this.Value.X
          local t2 = testDef this.Value.Y
          local t3 = testDef this.Value.W
          local t4 = testDef this.Value.H
          local o1 = testDef obj.Value.X
          local o2 = testDef obj.Value.Y
          local o3 = testDef obj.Value.W
          local o4 = testDef obj.Value.H
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3 and t4.Equals o4
        )
        (this.IsBox3() and obj.IsBox3()): (
          local t1 = testDef this.Value.Min
          local t2 = testDef this.Value.Max
          local o1 = testDef obj.Value.Min
          local o2 = testDef obj.Value.Max
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsDataPair() and obj.IsDataPair()): (
          local t1 = testDef this.Value.V1
          local t2 = testDef this.Value.V2
          local t3 = testDef (getPropNames this.Value)
          local o1 = testDef obj.Value.V1
          local o2 = testDef obj.Value.V2
          local o3 = testDef (getPropNames obj.Value)
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsEulerAngles() and obj.IsEulerAngles()): (
          local t1 = testDef this.Value.X
          local t2 = testDef this.Value.Y
          local t3 = testDef this.Value.Z
          local o1 = testDef obj.Value.X
          local o2 = testDef obj.Value.Y
          local o3 = testDef obj.Value.Z
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsInterval() and obj.IsInterval()): (
          local t1 = testDef this.Value.Start
          local t2 = testDef this.Value.End
          local o1 = testDef obj.Value.Start
          local o2 = testDef obj.Value.End
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsMatrix3() and obj.IsMatrix3()): (
          local t1 = testDef this.Value[1]
          local t2 = testDef this.Value[2]
          local t3 = testDef this.Value[3]
          local t4 = testDef this.Value[4]
          local o1 = testDef obj.Value[1]
          local o2 = testDef obj.Value[2]
          local o3 = testDef obj.Value[3]
          local o4 = testDef obj.Value[4]
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3 and t4.Equals o4
        )
        (this.IsNumber() and obj.IsNumber()): (
          -- 0.0との比較はfalseを返すため1を足して比較する
          local f1 = obj.Value as Float + 1.0
          local f2 = this.Value as Float + 1.0
          close_enough f1 f2 10
        )
        (this.IsPoint2() and obj.IsPoint2()): (
          local t1 = testDef this.Value.X
          local t2 = testDef this.Value.Y
          local o1 = testDef obj.Value.X
          local o2 = testDef obj.Value.Y
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsPoint3() and obj.IsPoint3()): (
          local t1 = testDef this.Value.X
          local t2 = testDef this.Value.Y
          local t3 = testDef this.Value.Z
          local o1 = testDef obj.Value.X
          local o2 = testDef obj.Value.Y
          local o3 = testDef obj.Value.Z
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsPoint4() and obj.IsPoint4()): (
          local t1 = testDef this.Value.X
          local t2 = testDef this.Value.Y
          local t3 = testDef this.Value.Z
          local t4 = testDef this.Value.W
          local o1 = testDef obj.Value.X
          local o2 = testDef obj.Value.Y
          local o3 = testDef obj.Value.Z
          local o4 = testDef obj.Value.W
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3 and t4.Equals o4
        )
        (this.IsQuat() and obj.IsQuat()): (
          local t1 = testDef this.Value.Angle
          local t2 = testDef this.Value.Axis
          local o1 = testDef obj.Value.Angle
          local o2 = testDef obj.Value.Axis
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsRay() and obj.IsRay()): (
          local t1 = testDef this.Value.Pos
          local t2 = testDef this.Value.Dir
          local o1 = testDef obj.Value.Pos
          local o2 = testDef obj.Value.Dir
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsRegexObject() and obj.IsRegexObject()): (
          local t1 = testDef (this.Value.ToString())
          local t2 = testDef this.Value.Options
          local o1 = testDef (obj.Value.ToString())
          local o2 = testDef obj.Value.Options
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsString() and obj.IsString()): (
          if this.IgnoreCase then (
            stricmp obj.Value this.Value == 0
          )
          else (
            obj.Value == this.Value
          )
        )
        default: (
          if this.HasEquals() and not this.IsDotNetClass() then (
            this.Value.Equals obj.Value
          )
          else (
            obj.Value == this.Value
          )
        )
      )
    )
    isEquals
  ),

  /**
  `Equals`メソッドを持っているかどうかを判定する。
  @return <BooleanClass>
  */
  public fn HasEquals = (
    this.HasProp #Equals and (
      classOf this.Value.Equals == MaxScriptFunction \
          or classOf this.Value.Equals == DotNetMethod
    )
  ),

  /**
  現在のオブジェクトの値が指定したプロパティを持っているかどうかを判定する。
  @param propName <String|Name>
  @return <BooleanClass>
  */
  public fn HasProp propName = (
    isProperty this.Value propName
  ),

  /** @return <BooleanClass> */
  public fn IsAngleAxis = classOf this.Value == AngleAxis,
  /** @return <BooleanClass> */
  public fn IsArray = classOf this.Value == Array,
  /** @return <BooleanClass> */
  public fn IsArrayOrArrayParameter = this.IsArray() or this.IsArrayParameter(),
  /** @return <BooleanClass> */
  public fn IsArrayParameter = classOf this.Value == ArrayParameter,
  /** @return <BooleanClass> */
  public fn IsAttributeDef = classOf this.Value == AttributeDef,
  /** @return <BooleanClass> */
  public fn IsBigMatrix = classOf this.Value == BigMatrix,
  /** @return <BooleanClass> */
  public fn IsBinStream = classOf this.Value == BinStream,
  /** @return <BooleanClass> */
  public fn IsBitArray = classOf this.Value == BitArray,
  /** @return <BooleanClass> */
  public fn IsBitmap = classOf this.Value == Bitmap,
  /** @return <BooleanClass> */
  public fn IsBoolean = classOf this.Value == BooleanClass,
  /** @return <BooleanClass> */
  public fn IsBox2 = classOf this.Value == Box2,
  /** @return <BooleanClass> */
  public fn IsBox3 = classOf this.Value == Box3,
  /** @return <BooleanClass> */
  public fn IsColor = classOf this.Value == Color,
  /** @return <BooleanClass> */
  public fn IsDataPair = classOf this.Value == DataPair,
  /** @return <BooleanClass> */
  public fn IsDotNetClass = classOf this.Value == DotNetClass,
  /** @return <BooleanClass> */
  public fn IsDotNetMethod = classOf this.Value == DotNetMethod,
  /** @return <BooleanClass> */
  public fn IsDotNetObject = classOf this.Value == DotNetObject,
  /** @return <BooleanClass> */
  public fn IsEulerAngles = classOf this.Value == EulerAngles,
  /** @return <BooleanClass> */
  public fn IsFileStream = classOf this.Value == FileStream,
  /** @return <BooleanClass> */
  public fn IsFloat = classOf this.Value == Float,
  /** @return <BooleanClass> */
  public fn IsInteger = classOf this.Value == Integer,
  /** @return <BooleanClass> */
  public fn IsInterval = classOf this.Value == Interval,
  /** @return <BooleanClass> */
  public fn IsMatrix3 = classOf this.Value == Matrix3,
  /** @return <BooleanClass> */
  public fn IsMAXKey = classOf this.Value == MAXKey,
  /** @return <BooleanClass> */
  public fn IsMAXScriptFunction = classOf this.Value == MAXScriptFunction,
  /** @return <BooleanClass> */
  public fn IsName = classOf this.Value == Name,
  /** @return <BooleanClass> */
  public fn IsNumber = superClassOf this.Value == Number,
  /** @return <BooleanClass> */
  public fn IsOk = classOf this.Value == OkClass,
  /** @return <BooleanClass> */
  public fn IsPoint2 = classOf this.Value == Point2,
  /** @return <BooleanClass> */
  public fn IsPoint3 = classOf this.Value == Point3,
  /** @return <BooleanClass> */
  public fn IsPoint4 = classOf this.Value == Point4,
  /** @return <BooleanClass> */
  public fn IsQuat = classOf this.Value == Quat,
  /** @return <BooleanClass> */
  public fn IsRay = classOf this.Value == Ray,
  /** @return <BooleanClass> */
  public fn IsRegexObject = (
    classOf this.Value == DotNetObject \
        and this.regexType.IsInstanceOfType this.Value
  ),
  /** @return <BooleanClass> */
  public fn IsRollout = classOf this.Value == RolloutClass,
  /** @return <BooleanClass> */
  public fn IsString = classOf this.Value == String,
  /** @return <BooleanClass> */
  public fn IsStringStream = classOf this.Value == StringStream,
  /** @return <BooleanClass> */
  public fn IsStructDefinition = isStructDef this.Value,
  /** @return <BooleanClass> */
  public fn IsStructInstance = isStruct this.Value,
  /** @return <BooleanClass> */
  public fn IsTestValue obj = classOf obj == classOf this,
  /** @return <BooleanClass> */
  public fn IsTime = classOf this.Value == Time,
  /** @return <BooleanClass> */
  public fn IsUndefined = classOf this.Value == UndefinedClass,
  /** @return <BooleanClass> */
  public fn IsUnsupplied = classOf this.Value == UnsuppliedClass,
  /** @return <BooleanClass> */
  public fn IsWindowStream = classOf this.Value == WindowStream,

  on Create do (
    this.regexType = (DotNetObject this.regexClass "").GetType()
  )
)
