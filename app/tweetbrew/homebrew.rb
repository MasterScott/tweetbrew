require "unirest"

class Tap
  attr_reader :user, :repo

  def initialize(repo_name)
    @user, @repo = repo_name.split("/", 2)
  end

  def official?
    user == "Homebrew"
  end

  def core?
    official? && (repo == "homebrew" || repo == "linuxbrew")
  end

  def name
    if core?
      repo[0].upcase + repo[1..-1]
    else
      "#{user}/#{repo.sub "homebrew-", ""}"
    end
  end

  def formula?(file)
    if core?
      %r{^Library/Formula/[^/]+\.rb$} === file
    else
      %r{^((Homebrew)?Formula/)?[^/]+\.rb$} === file
    end
  end

  def get_file(file)
    Unirest.get("https://raw.githubusercontent.com/#{user}/#{repo}/master/#{file}").raw_body
  end
end

class Formula
  attr_reader :name, :tap, :path

  def initialize(tap, path)
    @tap = tap
    @path = path
    @name = File.basename(path, ".rb")
  end

  def code
    @code ||= tap.get_file(path)
  end

  def homepage
    @homepage ||= code[/homepage ['"]([^'"]+)['"]/, 1]
  end

  def doi
    @doi ||= code[/doi ['"]([^'"]+)['"]/, 1]
  end

  def tag
    @tag ||= code[/tag ['"]([^'"]+)['"]/, 1]
  end
end
