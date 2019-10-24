module HTTP
  class Message
    class Headers
      def set_request_header
        return if @dumped
        @dumped = true
        keep_alive = Message.keep_alive_enabled?(@http_version)
        if !keep_alive and @request_method != 'CONNECT'
          set('Connection', 'close')
        end
        if @chunked
          set('Transfer-Encoding', 'chunked')
        elsif @body_size and (keep_alive or @body_size != 0)
          set('Content-Length', @body_size.to_s)
        end
        if @http_version >= '1.1' and get('Host').empty?
          if @request_uri.port == @request_uri.default_port
            # GFE/1.3 dislikes default port number (returns 404)
            set('Host', "#{@request_uri.host}")
          else
            set('Host', "#{@request_uri.host}:#{@request_uri.port}")
          end
        end
      end
    end
  end
end