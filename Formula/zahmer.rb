# Formula for the Zahmer CLI (not a cask).
#
# Source:  https://github.com/Radovetskyi/zahmer-cli
# Tap:     https://github.com/Radovetskyi/homebrew-zahmer
# Install: brew tap Radovetskyi/zahmer && brew install zahmer
#
# After tagging v0.1.0 on zahmer-cli, refresh sha256:
#   curl -sL https://github.com/Radovetskyi/zahmer-cli/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
#
# Homebrew's pip helper uses --no-deps, so we call pip ourselves (deps from PyPI).
# Claude / cursor-agent are optional — not formula deps.

class Zahmer < Formula
  include Language::Python::Virtualenv

  desc "Cost-aware hierarchical AI agent orchestration CLI"
  homepage "https://github.com/Radovetskyi/zahmer-cli"
  license "MIT"
  version "0.1.0"

  url "https://github.com/Radovetskyi/zahmer-cli/archive/refs/tags/v#{version}.tar.gz"
  sha256 "81dc448cb44592aae6633672a27a855b59e628755e6efec7633e52e8eaf7c488"

  head "https://github.com/Radovetskyi/zahmer-cli.git", branch: "main"

  depends_on "python@3.13"

  def install
    virtualenv_create(libexec, "python3.13")
    py = Formula["python@3.13"].opt_libexec/"bin/python"
    # Install into the formula venv (wheels from PyPI, including pydantic-core).
    system py, "-m", "pip", "--python=#{libexec}/bin/python", "install", "--upgrade", "pip"
    system py, "-m", "pip", "--python=#{libexec}/bin/python", "install", buildpath
    bin.install_symlink libexec/"bin/zahmer"
  end

  def caveats
    <<~EOS
      Live runs need an agent CLI on PATH (optional for the offline stub):
        brew install --cask claude-code    # --backend claude
        brew install --cask cursor-cli     # --backend cursor
      Then:  zahmer doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zahmer version")
    assert_match "'ok': True", shell_output("#{bin}/zahmer doctor")
  end
end
