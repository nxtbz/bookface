class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  validates_presence_of :username 
  validates_uniqueness_of :username

  has_many :friendships, dependent: :destroy
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :posts, dependent: :destroy 

  def request_friendship(user2)
    self.friendships.create(friend_id: user2.id)    
  end

  def pending_friends_requests_from
    self.friendships.where(state: "pending")
  end

  def pending_friends_requests_to
    self.inverse_friendships.where(state: "pending")
  end

  def active_friends
    self.friendships.where(state: "accepted").map(&:friend) + self.inverse_friendships.where(state: "accepted").map(&:user)    
  end

  def friendship_status(user_2)
    friendship = Friendship.where(user_id: [self.id, user_2.id], friend_id:[self.id, user_2.id])
    unless friendship.any? 
      return "not_friends"
    else
      if friendship.first.state == "accepted"
        return "friends"
      else
        if friendship.first.user == self 
          return "pending"
        else 
          return "requested"
        end
      end
    end
  end

  def friendship_relation(user_2)
    Friendship.where(user_id: [self.id, user_2.id], friend_id:[self.id, user_2.id]).first
  end
  
end
