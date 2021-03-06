require 'yt/collections/base'
require 'yt/models/comment'

module Yt
  module Collections
    # Provides methods to interact with a collection of YouTube comments.
    class Comments < Resources

      def where(requirements = {})
        @published_before = nil
        super
      end

      def reject(comment_id)
        moderation_status_params = {id: comment_id, moderation_status: 'rejected'}
        do_set_moderation_status(moderation_status_params)
      end

    private

      def attributes_for_new_item(data)
        {}.tap do |attributes|
          attributes[:id] = data['id']
          attributes[:video_id] = data['videoId']
          attributes[:snippet] = data['snippet']
          attributes[:etag] = data['etag']
          attributes[:auth] = @auth
        end
      end

      # @return [Hash] the parameters to submit to YouTube to list videos.
      # @see https://developers.google.com/youtube/v3/docs/search/list
      def list_params
        super.tap do |params|
          params[:params] = comments_params
          params[:path] = comments_path
        end
      end

      def comments_params
        {}.tap do |params|
          params[:parent_id] = @parent.id
          params[:max_results] = 100
          params[:part] = 'snippet'
          params[:order] = 'time'
          params[:text_format] = 'plainText'
          params[:published_before] = @published_before if @published_before
          apply_where_params! params
        end
      end

      def comments_path
        '/youtube/v3/comments'
      end

      def insert_parts
        {snippet: {keys: [:text_original, :parent_id]}}
      end
    end
  end
end