/*! © 2015 imaoki | MIT License | https://github.com/imaoki */
(
  local pathClass = DotNetClass "System.IO.Path"

  local currentDir = pathClass.GetDirectoryName (getSourceFileName())
  local parentDir = pathClass.GetDirectoryName currentDir

  local testValueFile = parentDir + @"\TestValue.ms"
  local unitTestFile = parentDir + @"\UnitTest.ms"

  fileIn testValueFile
  format "evaluated: @\"%\"\n" testValueFile
  fileIn unitTestFile
  format "evaluated: @\"%\"\n" unitTestFile

  ::unitTest = ::UnitTest()
  format "defined: ::unitTest\n"
  ok
)
