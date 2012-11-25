module GitBrowser::App::Views

   class CommitEntry

      def initialize(repobrowser, commit)
         @repobrowser = repobrowser
         @commit = commit
      end

      def link
         @repobrowser.commit_url @commit
      end

      def short_hash
         @commit.short_hash
      end

      def date
         @commit.date.strftime('%d/%m/%Y at %H:%M:%S')
      end

      def message
         @commit.message.split("\n")[0]
      end

      def author
         @author ||= @commit.author
      end

      def author_name
         author.name
      end

      def author_email
         @author_email ||= author.email
      end

      def author_avatar
         avatar_digest = Digest::MD5.hexdigest(author_email)
         @author_avatar = "http://gravatar.com/avatar/#{avatar_digest}?s=40"
      end
   end
end
