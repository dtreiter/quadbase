# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionListsController < ApplicationController
  before_filter :include_jquery, :only => [:show, :index]
  before_filter :include_mathjax, :only => :show

  before_filter :use_2_column_layout
  before_filter {select_tab(:question_lists)}

  helper :questions

  def index
    respond_with(@question_list_members = current_user.question_list_members)
  end
  
  def show
    @question_list = QuestionList.find(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@question_list)
    @target_question_lists = current_user.question_lists.reject { |w| w == @question_lists}
    respond_with(@question_lists)
  end
  
  def new
    respond_with(@question_list = QuestionList.new)
  end
  
  def edit
    @question_list = QuestionList.find(params[:id])
    raise SecurityTransgression unless present_user.can_update?(@question_list)
    respond_with(@question_list)
  end
  
  def create
    @question_list = QuestionList.new(params[:question_list])
    raise SecurityTransgression unless present_user.can_create?(@question_list)
    
    QuestionList.transaction do
      @question_list.save
      @question_list.add_member!(current_user)
    end
    respond_with(@question_list)
  end
  
end
