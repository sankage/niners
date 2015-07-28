class Player < ActiveRecord::Base

  class GroupError < StandardError; end

  scope :recent, -> {
    where("created_at >= ?", last_tuesday)
  }
  scope :semi_recent, -> { where("created_at >= ?", 12.days.ago) }

  def self.last_tuesday
    today = Time.now
    diff = ((today.wday + 5) % 7)
    if diff == 0 && today.at_noon < today
      diff = 7
    end
    (today - diff.days).at_noon
  end

  def self.groupings(force: false)
    if force
      last_entry = OpenStruct.new(created_at: Date.new(2000,1,1))
    else
      last_entry = History.last || OpenStruct.new(created_at: Date.new(2000,1,1))
    end
    if last_entry.created_at >= last_tuesday
      deserialize_groups(last_entry.serialized_groups)
    else
      make_groups
    end
  rescue GroupError
    make_groups
  end

  def self.make_groups
    return [] if recent.count == 0
    groups = patterned_groups.each_slice(4).to_a
    if groups.last.size == 2
      groups = groups + groups.pop(2).flatten.each_slice(3).to_a
    elsif groups.last.size == 1
      groups = groups + groups.pop(3).flatten.each_slice(3).to_a
    end
    serialize_and_store(groups)
    groups
  end

  def self.patterned_groups
    walkers = recent.where(walker: true, rider: false).to_a.shuffle.each_slice(2).to_a
    riders = recent.where(walker: false, rider: true).to_a.shuffle.each_slice(2).to_a
    either = recent.where(walker: false, rider: false).to_a.shuffle.each_slice(2).to_a
    either += recent.where(walker: true, rider: true).to_a.shuffle.each_slice(2).to_a
    remainders = []
    if walkers.last && walkers.last.size == 1
      remainders.push walkers.pop
    end
    if riders.last && riders.last.size == 1
      remainders.push riders.pop
    end
    if walkers.size >= riders.size
      (walkers.zip(riders) + remainders + either).flatten.compact
    else
      (riders.zip(walkers) + remainders + either).flatten.compact
    end
  end

  def self.serialize_and_store(groups)
    ids_only = groups.map { |group| group.map(&:id) }
    History.create!(serialized_groups: ids_only)
  end

  def self.deserialize_groups(id_array)
    players = Player.semi_recent
    force_regroup = -> { raise GroupError }
    id_array.map { |group|
      group.map { |pid|
        players.detect(force_regroup) { |p| p.id == pid }
      }
    }
  end

  validates :name, presence: true

  def type
    types = []
    types.push "Walker" if walker?
    types.push "Rider" if rider?
    types.push "Walker", "Rider" if !walker? && !rider?
    types.join("/")
  end
end
