module CollectionHandler

  def self.included(base)
    base.extend(ModuleMethods)
  end

  module ModuleMethods
    @initialized = false

    # Overwrite for more complex behaviour
    def initialization_needed?
      !@initialized
    end

    def included(base)
      if initialization_needed?
        init_store
        @initialized = true
      end
    end

    def init_store
      raise "Please provide an implementation of init_store"
    end

  end

  # Abstract methods
  %w( iterator keylist get set ).each do |method|
    define_method(method) do
      raise "Please provide an implementation of #{method}"
    end
  end

end
