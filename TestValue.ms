/*! © 2015 imaoki | MIT License | https://github.com/imaoki */
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
  指定したオブジェクトが現在のオブジェクトと等しいかどうかを判断する。
  @param obj <TestValue>
  @return <BooleanClass>
  @remark
  * 数値で構成される複合値は各要素の数値を`==`演算子ではなく`close_enough`関数を用いて比較する。

  * 配列の場合は全ての要素を再帰的に比較する。

  * `Equals`メソッドを持っているオブジェクトは`Equals`メソッドを使用する。

  * 正規表現オブジェクトは`ToString`メソッドによるパターン文字列と`Options`プロパティをそれぞれ比較する。
  */
  public fn Equals obj = (
    local isEquals = false
    if this.IsTestValue obj do (
      isEquals = case of (
        (this.IsAngleAxis() and obj.IsAngleAxis()): (
          local t1 = ::TestValue this.Value.Angle
          local t2 = ::TestValue this.Value.Axis
          local t3 = ::TestValue this.Value.NumRevs
          local o1 = ::TestValue obj.Value.Angle
          local o2 = ::TestValue obj.Value.Axis
          local o3 = ::TestValue obj.Value.NumRevs
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (
          (this.IsArray() or this.IsArrayParameter()) \
              and (obj.IsArray() or obj.IsArrayParameter())
        ): (
          local result = obj.Value.Count == this.Value.Count
          for i = 1 to this.Value.Count while result do (
            local t1 = ::TestValue this.Value[i]
            local o1 = ::TestValue obj.Value[i]
            result = t1.Equals o1
          )
          result
        )
        (this.IsBigMatrix() and obj.IsBigMatrix()): (
          local result = obj.Value.Rows == this.Value.Rows \
              and obj.Value.Columns == this.Value.Columns
          for i = 1 to this.Value.Rows while result do (
            for j = 1 to this.Value.Columns while result do (
              local t1 = ::TestValue this.Value[i][j]
              local o1 = ::TestValue obj.Value[i][j]
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
          local t1 = ::TestValue this.Value.X
          local t2 = ::TestValue this.Value.Y
          local t3 = ::TestValue this.Value.W
          local t4 = ::TestValue this.Value.H
          local o1 = ::TestValue obj.Value.X
          local o2 = ::TestValue obj.Value.Y
          local o3 = ::TestValue obj.Value.W
          local o4 = ::TestValue obj.Value.H
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3 and t4.Equals o4
        )
        (this.IsBox3() and obj.IsBox3()): (
          local t1 = ::TestValue this.Value.Min
          local t2 = ::TestValue this.Value.Max
          local o1 = ::TestValue obj.Value.Min
          local o2 = ::TestValue obj.Value.Max
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsDataPair() and obj.IsDataPair()): (
          local t1 = ::TestValue this.Value.V1
          local t2 = ::TestValue this.Value.V2
          local t3 = ::TestValue (getPropNames this.Value)
          local o1 = ::TestValue obj.Value.V1
          local o2 = ::TestValue obj.Value.V2
          local o3 = ::TestValue (getPropNames obj.Value)
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsEulerAngles() and obj.IsEulerAngles()): (
          local t1 = ::TestValue this.Value.X
          local t2 = ::TestValue this.Value.Y
          local t3 = ::TestValue this.Value.Z
          local o1 = ::TestValue obj.Value.X
          local o2 = ::TestValue obj.Value.Y
          local o3 = ::TestValue obj.Value.Z
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsInterval() and obj.IsInterval()): (
          local t1 = ::TestValue this.Value.Start
          local t2 = ::TestValue this.Value.End
          local o1 = ::TestValue obj.Value.Start
          local o2 = ::TestValue obj.Value.End
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsMatrix3() and obj.IsMatrix3()): (
          local t1 = ::TestValue this.Value[1]
          local t2 = ::TestValue this.Value[2]
          local t3 = ::TestValue this.Value[3]
          local t4 = ::TestValue this.Value[4]
          local o1 = ::TestValue obj.Value[1]
          local o2 = ::TestValue obj.Value[2]
          local o3 = ::TestValue obj.Value[3]
          local o4 = ::TestValue obj.Value[4]
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3 and t4.Equals o4
        )
        (this.IsNumber() and obj.IsNumber()): (
          -- 0.0との比較はfalseを返すため1を足して比較する
          local f1 = obj.Value as Float + 1.0
          local f2 = this.Value as Float + 1.0
          close_enough f1 f2 10
        )
        (this.IsPoint2() and obj.IsPoint2()): (
          local t1 = ::TestValue this.Value.X
          local t2 = ::TestValue this.Value.Y
          local o1 = ::TestValue obj.Value.X
          local o2 = ::TestValue obj.Value.Y
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsPoint3() and obj.IsPoint3()): (
          local t1 = ::TestValue this.Value.X
          local t2 = ::TestValue this.Value.Y
          local t3 = ::TestValue this.Value.Z
          local o1 = ::TestValue obj.Value.X
          local o2 = ::TestValue obj.Value.Y
          local o3 = ::TestValue obj.Value.Z
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3
        )
        (this.IsPoint4() and obj.IsPoint4()): (
          local t1 = ::TestValue this.Value.X
          local t2 = ::TestValue this.Value.Y
          local t3 = ::TestValue this.Value.Z
          local t4 = ::TestValue this.Value.W
          local o1 = ::TestValue obj.Value.X
          local o2 = ::TestValue obj.Value.Y
          local o3 = ::TestValue obj.Value.Z
          local o4 = ::TestValue obj.Value.W
          t1.Equals o1 and t2.Equals o2 and t3.Equals o3 and t4.Equals o4
        )
        (this.IsQuat() and obj.IsQuat()): (
          local t1 = ::TestValue this.Value.Angle
          local t2 = ::TestValue this.Value.Axis
          local o1 = ::TestValue obj.Value.Angle
          local o2 = ::TestValue obj.Value.Axis
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsRay() and obj.IsRay()): (
          local t1 = ::TestValue this.Value.Pos
          local t2 = ::TestValue this.Value.Dir
          local o1 = ::TestValue obj.Value.Pos
          local o2 = ::TestValue obj.Value.Dir
          t1.Equals o1 and t2.Equals o2
        )
        (this.IsRegexObject() and obj.IsRegexObject()): (
          local t1 = ::TestValue (this.Value.ToString())
          local t2 = ::TestValue this.Value.Options
          local o1 = ::TestValue (obj.Value.ToString())
          local o2 = ::TestValue obj.Value.Options
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
  `Equals`メソッドを持っているかどうかを判断する。
  @return <BooleanClass>
  */
  public fn HasEquals = (
    this.HasProp #Equals and (
      classOf this.Value.Equals == MaxScriptFunction \
          or classOf this.Value.Equals == DotNetMethod
    )
  ),

  /**
  現在のオブジェクトの値が指定したプロパティを持っているかどうかを判断する。
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
