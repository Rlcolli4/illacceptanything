require 'active_support/core_ext/module/attr_internal'

module ActiveRecord
  module Rails
    module ControllerRuntime
      extend ActiveSupport::Concern

      attr_internal :db_runtime

      def cleanup_view_runtime
        if ActiveRecord::Base.connected?
          db_rt_before_render = ActiveRecord::Base.connection.reset_runtime
          runtime = super
          db_rt_after_render = ActiveRecord::Base.connection.reset_runtime
          self.db_runtime = db_rt_before_render + db_rt_after_render
          runtime - db_rt_after_render
        else
          super
        end
      end

      module ClassMethods
        def log_process_action(controller)
          super
          db_runtime = controller.send :db_runtime
          logger.info("  ActiveRecord runtime: %.1fms" % db_runtime.to_f) if db_runtime
        end
      end
    end
  end
end
