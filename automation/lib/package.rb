require 'yaml'

class Package

  def initialize(file_text)
    @directives = {}
    chunks = file_text.split("\n\n")
    chunks.each { |chunk|
      parsed = YAML.load(chunk)
      @directives.merge!(parsed) if parsed.instance_of? Hash
    }
  end

  def name
    @directives['name']
  end

  def version
    @directives['version'].to_s
  end

  def configure
    [ './configure --prefix=/usr' ]
  end

  def make
    [ 'make' ]
  end

  def test
    [ 'make check' ]
  end

  def install
    [ 'make install' ]
  end

end
