# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionList < ActiveRecord::Base
  has_many :question_list_members, :dependent => :destroy
  has_many :members, :through => :question_list_members, :source => :user
  
  has_many :question_list_questions, :dependent => :destroy
  has_many :questions, :through => :question_list_questions
  
  has_one :comment_thread, :as => :commentable, :dependent => :destroy
  before_validation :build_comment_thread, :on => :create
  validates_presence_of :comment_thread
  
  accepts_nested_attributes_for :question_list_members, :allow_destroy => true
  accepts_nested_attributes_for :question_list_questions, :allow_destroy => true

  attr_accessible :name, :question_list_members_attributes
  attr_accessible :question_list_questions_attributes  
  
  # Returns the default question list for the specified user.  If no such question list
  # exists, makes a new one and returns it.  
  def self.default_for_user!(user)    
    default_member = QuestionListMember.default_for_user(user)
    
    if default_member.nil?
      new_question_list = QuestionList.create(:name => user.full_name + "'s Question List")
      default_member = QuestionListMember.create(:user => user, :question_list => new_question_list)
      default_member.make_default!
    end
    default_member.question_list
  end
  
  
  def self.all_for_user(user)
    QuestionListMember.all_for_user(user).collect{|wm| wm.question_list}
  end
  
  def is_default_for_user?(user)
    default_member = QuestionListMember.default_for_user(user)
    return false if default_member.nil?
    self == default_member.question_list
  end
  
  def add_question!(question)
    QuestionListQuestion.create(:question_list => self, :question => question)
  end
  
  def add_member!(member)
    QuestionListMember.create(:question_list => self, :user => member)
  end
  
  def is_member?(user)
    members.include?(user)
  end

  def has_question?(question, reload=true)
    questions(reload).include?(question)
  end

  def can_be_joined_by?(user)
    !is_member?(user)
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
    
  def can_be_created_by?(user)
    !user.is_anonymous?
  end
  
  def can_be_updated_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
  
end
