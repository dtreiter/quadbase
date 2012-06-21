# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionListMember < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :question_list
  
  validate :validate_max_one_default_question_list_per_user
  validates_uniqueness_of :user_id,
                            :scope => :question_list_id,
                            :message => "This user is already a member of this question list."
  
  after_destroy :destroy_memberless_question_list
  
  attr_accessible :user, :question_list, :user_id
  
  def make_default!
    return if is_default
    
    old_default_question_list_member = QuestionListMember.default_for_user(self.user)
    self.is_default = true

    if (old_default_question_list_member.nil?)
        self.save!
    else
        old_default_question_list_member.is_default = false
        QuestionListMember.transaction do
          old_default_question_list_member.save!
          self.save!
        end        
    end   
  end
  
  def self.default_for_user(user)
    QuestionListMember.defaults_for_user(user).first
  end
  
  def self.all_for_user(user)
    QuestionListMember.where{user_id == user.id}.all
  end

  def destroy_memberless_question_list
    if question_list.question_list_members.empty?
      question_list.destroy
    end
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_created_by?(user)
    !user.is_anonymous? && question_list.is_member?(user)
  end

  def can_be_updated_by?(user)
    !user.is_anonymous? && user == self.user
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && question_list.is_member?(user)
  end
  
  
end
