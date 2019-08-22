/*! © 2015 imaoki | MIT License | https://github.com/imaoki */
(
  local pathClass = DotNetClass "System.IO.Path"

  local currentDir = pathClass.GetDirectoryName (getSourceFileName())
  local parentDir = pathClass.GetDirectoryName currentDir

  local definitionFile = currentDir + @"\definition.ms"

  if GlobalVars.IsGlobal "startupScript" do (
    local code = StringStream ""
    format "fileIn @\"%\"" definitionFile to:code
    code = code as String
    ::startupScript.RegisterScript code id:"UnitTest"
    ::startupScript.Save()
    ::startupScript.Evaluate()
  )
  ok
)
