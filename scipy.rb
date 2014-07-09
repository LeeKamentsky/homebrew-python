require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'https://downloads.sourceforge.net/project/scipy/scipy/0.13.2/scipy-0.13.2.tar.gz'
  sha1 'b0713c962a4a94daad55fd8c67e5aa21d2336a3d'
  head 'https://github.com/scipy/scipy.git'

  depends_on :python => :recommended

  numpy_options = []
  depends_on "numpy" => numpy_options

  def install
    config = <<-EOS.undent
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include

      [amd]
      amd_libs = amd, cholmod, colamd, ccolamd, camd, suitesparseconfig
      [umfpack]
      umfpack_libs = umfpack

    EOS
    # The Accelerate.framework uses a g77 ABI
    ENV.append 'FFLAGS', '-ff2c'

    # https://github.com/Homebrew/homebrew-python/issues/110
    # There are ongoing problems with gcc+accelerate.
    odie "Please use brew install --with-openblas scipy to compile scipy using gcc." if ENV.compiler =~ /gcc-(4\.[3-9])/

    # https://github.com/Homebrew/homebrew-python/pull/73
    # Only save for gcc and allows you to `brew install scipy --cc=gcc-4.8`
    # ENV.append 'CPPFLAGS', '-D__ACCELERATE__' if ENV.compiler =~ /gcc-(4\.[3-9])/

    Pathname('site.cfg').write config

    if HOMEBREW_CELLAR.subdirs.map{ |f| File.basename f }.include? 'gfortran'
        opoo <<-EOS.undent
            It looks like the deprecated gfortran formula is installed.
            This causes build problems with scipy. gfortran is now provided by
            the gcc formula. Please run:
                brew rm gfortran
                brew install gcc
            if you encounter problems.
        EOS
    end

    # gfortran is gnu95
    system "python", "setup.py", "build", "install", "--prefix=#{prefix}"
  end

end
