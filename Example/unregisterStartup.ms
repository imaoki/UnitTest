/*! © 2019 imaoki | MIT License | https://github.com/imaoki */
(
  if GlobalVars.IsGlobal "startupScript" do (
    ::startupScript.UnregisterScript id:"UnitTest"
    ::startupScript.Save()
  )
  ok
)
