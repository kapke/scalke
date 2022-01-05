import scala.sys.process.Process

Global / onChangedBuildSource := ReloadOnSourceChanges

lazy val root = (project in file("."))
  .enablePlugins(ScalaJSPlugin, ScalablyTypedConverterExternalNpmPlugin)
  .settings(
    scalaVersion := "3.1.0",
    // scalacOptions += "-Xsource:3",
    scalaJSLinkerConfig ~= { _.withModuleKind(ModuleKind.ESModule) },
    stEnableScalaJsDefined := Selection.All,
    externalNpm := {
      val log = streams.value.log
      val baseDir = baseDirectory.value
      val rootDirectory = baseDir.getParentFile.getParentFile
      val rootNodeModules = rootDirectory / "node_modules"

      Process(s"ln -s ${rootNodeModules.getAbsolutePath}", baseDir).!!

      baseDir
    },
    stIgnore += "rxjs",
    libraryDependencies ++= Seq(
      "org.typelevel" %%% "cats-core" % "2.7.0",
      "io.monix" %%% "monix" % "3.4.0",
    )
  )

lazy val dist = taskKey[Unit]("Builds the lib")
dist := {
  val log = streams.value.log
  (root / Compile / fullOptJS).value
  val targetJSDir = (root / Compile / fullLinkJS / scalaJSLinkerOutputDirectory).value
  val targetDir = (root / Compile / target).value
  val resDir = (root / Compile / resourceDirectory).value
  val distDir = targetDir / "dist"
  IO.createDirectory(distDir)
  IO.copyDirectory(targetJSDir, distDir, overwrite = true)
  IO.copyDirectory(resDir, distDir, overwrite = true)
  log.info(s"Dist done at ${distDir.absolutePath}")
}
