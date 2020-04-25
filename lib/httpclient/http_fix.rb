# frozen_string_literal: true

module HTTP
  class Message
    class Headers
      def set_request_header
        return if @dumped

        @dumped = true
        keep_alive = Message.keep_alive_enabled?(@http_version)
        set('Connection', 'close') if !keep_alive && (@request_method != 'CONNECT')
        if @chunked
          set('Transfer-Encoding', 'chunked')
        elsif @body_size && (keep_alive || (@body_size != 0))
          set('Content-Length', @body_size.to_s)
        end

        return unless (@http_version >= '1.1') && get('Host').empty?

        if @request_uri.port == @request_uri.default_port
          # GFE/1.3 dislikes default port number (returns 404)
          set('Host', @request_uri.host.to_s)
        else
          set('Host', "#{@request_uri.host}:#{@request_uri.port}")
        end
      end
    end
  end
end
