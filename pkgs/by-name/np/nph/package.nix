{
  lib,
  fetchFromGitHub,
  buildNimPackage,
}:

buildNimPackage (finalAttrs: {
  pname = "nph";
  version = "0.7.0";

  postPatch = ''
    substituteInPlace src/nph.nim \
      --replace-fail 'git describe --long --dirty --always --tags' "echo ${finalAttrs.version}" \
      --replace-fail 'doAssert NimMajor == 2 and NimMinor == 2, "nph needs a specific version of Nim"' 'doAssert NimMajor == 2, "nph needs Nim 2.x"'
  '';

  src = fetchFromGitHub {
    owner = "arnetheduck";
    repo = "nph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mH7yEyveR6cM7CFr93rO2K/5tAtKbawyTgbtU0kk5o8=";
  };

  lockFile = ./lock.json;

  checkPhase = ''
    runHook preCheck

    $out/bin/nph tests/before
    diff tests/before tests/after -x "*.yaml"

    runHook postCheck
  '';

  meta = {
    description = "Opinionated code formatter for Nim";
    homepage = "https://github.com/arnetheduck/nph";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "nph";
  };
})
