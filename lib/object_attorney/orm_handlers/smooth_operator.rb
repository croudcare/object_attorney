module ObjectAttorney
  module OrmHandlers

    module SmoothOperator

      def save(options = {})
        save!(options, :save)
      end

      def save!(options = {}, save_method = :save!)
        before_save
        save_result = valid? ? save_after_validations(save_method, options) : false
        after_save if valid? && save_result
        save_result
      end

      def destroy(options = {})
        return true if represented_object.blank?
        represented_object.destroy(options).ok?
      end

      def call_save_or_destroy(object, save_method, options = {})
        if object == self || object == represented_object
          represented_object.present? ? represented_object.send(save_method, options).ok? : true
        else
          save_method = :destroy if check_if_marked_for_destruction?(object)
          object.send(save_method, options).ok?
        end
      end

      protected #################### PROTECTED METHODS DOWN BELOW ######################

      def save_after_validations(save_method, options = {})
        submit(save_method, options)
      end

      def submit(save_method, options = {})
        save_result = save_or_destroy_nested_objects(save_method, :belongs_to, options)
        save_result = save_or_destroy_represented_object(save_method, options) if save_result
        save_result = save_or_destroy_nested_objects(save_method, :has_many, options) if save_result
        save_result
      end

      def save_or_destroy_represented_object(save_method, options = {})
        return true if represented_object.blank?
        call_save_or_destroy(represented_object, save_method, options)
      end

      def save_or_destroy_nested_objects(save_method, association_macro, options = {})
        nested_objects(association_macro).map do |reflection, nested_object|
          nested_object.send("#{self.class.represented_object_reflection.single_name}_id=", self.id) if represented_object.present? && association_macro == :has_many

          saving_result = call_save_or_destroy(nested_object, save_method, options)

          self.send("#{reflection.single_name}_id=", nested_object.id) if represented_object.present? && association_macro == :belongs_to

          saving_result
        end.all?
      end
      
    end

  end
end
