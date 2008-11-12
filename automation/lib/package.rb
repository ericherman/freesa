require 'yaml'

class Package

  def initialize(file_text)
    @text = file_text
  end

  def name
    extract_value('name')
  end

  def version
    extract_value('version')
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

  private

  def parse(text)
    directives = {}
    chunks.each { |chunk|
      parsed = YAML.load(chunk)
      directives.merge!(parsed) if parsed.instance_of? Hash
    }
  end

  def extract_value(keyword)
    line = @text.select { |line| line =~ /^#{keyword}:/ }
    line.first.gsub(/^[a-z]*:/, '').strip
  end

end
