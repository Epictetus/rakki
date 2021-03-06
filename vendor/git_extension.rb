require 'git'

module Git
  module LibExtensions
    def log_commits_follow(opts = {})
      count, since, object, path_limiter, follow =
        opts.values_at(:count, :since, :object, :path_limiter)
      from, to = *opts[:between]

      arr = ['--pretty=oneline', '--follow']
      arr << "-#{count}" if count
      arr << "--since='#{since}'" if since
      arr << "#{from}..#{to}" if from and to
      arr << object if object
      arr << "-- #{path_limiter}" if path_limiter

      command_lines('log', arr, true).map { |l| l.split.first }
    end

    def better_commit(message, opts = {})
      arr_opts = ["-m '#{message}'"]
      add_all, files, author = opts.values_at(:add_all, :files, :author)

      if add_all
        arr_opts << '-a'
      elsif files
        arr_opts += files.map{|f| f.to_s.dump }
      end

      arr_opts << "--author=#{author.to_s.dump}" if author
      command('commit', arr_opts)
    end

    # git ls-files [-z] [-t] [-v]
    #   (--[cached|deleted|others|ignored|stage|unmerged|killed|modified])*
    #   (-[c|d|o|i|s|u|k|m])*
    #   [-x <pattern>|--exclude=<pattern>]
    #   [-X <file>|--exclude-from=<file>]
    #   [--exclude-per-directory=<file>]
    #   [--exclude-standard]
    #   [--error-unmatch] [--with-tree=<tree-ish>]
    #   [--full-name] [--abbrev] [--] [<file>]*
    def ls_files_in(file, &block)
      command_lines('ls-files', file).each(&block)
    end

    def object_exists?(sha)
      command_lines('cat-file', ['-e', sha])
    end
  end

  # should use Forwardable?
  module BaseExtensions
    def better_commit(message, opts = {})
      lib.better_commit(message, opts)
    end

    def ls_files_in(file, &block)
      lib.ls_files_in(file, &block)
    end

    def object_exists?(sha)
      lib.object_exists?(sha)
    end
  end

  class Base
    include BaseExtensions
  end

  class Lib
    include LibExtensions
  end
end
