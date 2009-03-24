module Observable
  #
  # Add +observer+ as an observer on this object. +observer+ will now receive
  # notifications.
  #
  def add_observer(observer)
    @observer_peers = [] unless defined? @observer_peers
    @observer_peers.push observer
  end

  #
  # Delete +observer+ as an observer on this object. It will no longer receive
  # notifications.
  #
  def delete_observer(observer)
    @observer_peers.delete observer if defined? @observer_peers
  end

  #
  # Delete all observers associated with this object.
  #
  def delete_observers
    @observer_peers.clear if defined? @observer_peers
  end

  #
  # Return the number of observers associated with this object.
  #
  def count_observers
    if defined? @observer_peers
      @observer_peers.size
    else
      0
    end
  end

  #
  # If this object's changed state is +true+, invoke the update method in each
  # currently associated observer in turn, passing it the given arguments. The
  # changed state is then set to +false+.
  #
  def notify(method, *arg)
    if defined? @observer_peers
      for i in @observer_peers.dup
        if i.respond_to? method
          i.send(method, *arg)
        end
      end
    end
  end

end