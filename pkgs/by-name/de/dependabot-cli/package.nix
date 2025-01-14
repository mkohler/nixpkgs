{ buildGoModule
, dependabot-cli
, fetchFromGitHub
, fetchpatch
, installShellFiles
, lib
, testers
}:
let
  pname = "dependabot-cli";
  version = "1.39.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "dependabot";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-QuhgFWF97B72KTX/QKSXNl/4RDAKUMDga7vLYiZw4SM=";
  };

  vendorHash = "sha256-mNpNp/zeQGgcljj2VhGl4IN1HG1R8CJSTWKzrgC0z44=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dependabot/cli/cmd/dependabot/internal/cmd.version=v${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd dependabot \
      --bash <($out/bin/dependabot completion bash) \
      --fish <($out/bin/dependabot completion fish) \
      --zsh <($out/bin/dependabot completion zsh)
  '';

  checkFlags = [
    "-skip=TestIntegration|TestNewProxy_customCert|TestRun"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/dependabot --help
  '';

  passthru.tests.version = testers.testVersion {
    package = dependabot-cli;
    command = "dependabot --version";
    version = "v${version}";
  };

  meta = with lib; {
    changelog = "https://github.com/dependabot/cli/releases/tag/v${version}";
    description = "A tool for testing and debugging Dependabot update jobs";
    homepage = "https://github.com/dependabot/cli";
    license = licenses.mit;
    maintainers = with maintainers; [ l0b0 ];
  };
}
