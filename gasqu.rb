class Gasqu < Formula
  desc "gasqu on Zig"
  homepage "https://github.com/memm4587-ui/gasqu"
  
  
  url "https://github.com/memm4587-ui/gasqu/releases/download/0.1.0/gasqu-0.1.0.tar.gz"
  
  
  sha256 "c935b611d66906d8569618461518c7a95dd0ac3e89b42a41235c6fe370884aaf"
  
  version "0.1.0"

  def install
  
    bin.install "gasqu"
  end

  test do
  
    system "#{bin}/gasqu", "--version"
  end
end
