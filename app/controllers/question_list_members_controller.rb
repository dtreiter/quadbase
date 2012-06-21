# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionListMembersController < ApplicationController
  before_filter {select_tab(:question_lists)}
  
  before_filter :get_question_list, :only => [:search, :create]

  def new
    @action_dialog_title = "Add a member"
    @action_search_path = search_question_list_question_list_members_path(params[:question_list_id])
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  # This is for searching for new members
  def search
    raise SecurityTransgression unless present_user.can_update?(@question_list)
    
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      @question_list.is_member?(user)
    end    
    
    @action_partial = 'question_list_members/create_question_list_member_form'
    
    respond_to do |format|
      format.js { render :template => 'users/action_search' }
    end
  end

  def create
    raise SecurityTransgression unless present_user.can_update?(@question_list)

    username = params[:question_list_member][:username]
    user = User.find_by_username(username)

    if user.nil?
      flash[:alert] = 'User ' + username + ' not found!'
      respond_to do |format|
        format.html { redirect_to question_list_path(@question_list) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => {:base => 'Username not found.'}, :status => :unprocessable_entity }
      end
      return
    end

    @question_list_member = QuestionListMember.new(:user => user, :question_list => @question_list)
    
    raise SecurityTransgression unless present_user.can_create?(@question_list_member)

    respond_to do |format|
      if @question_list_member.save
        QuestionListMemberNotifier.question_list_member_created_email(
          @question_list_member, present_user)
        format.html { redirect_to question_list_path(@question_list) }
        format.js
      else
        flash[:alert] = @question_list_member.errors.values.to_sentence
        format.html { redirect_to question_list_path(@question_list) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => @question_list_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @question_list_member = QuestionListMember.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@question_list_member)
    
    respond_to do |format|
      if @question_list_member.destroy
        @question_list = @question_list_member.question_list
        format.html do
          if @question_list_member.user == present_user
            redirect_to question_lists_path
          else
            redirect_to question_list_path(@question_list)
          end
        end
        format.js
      else
        format.json { render :json => @question_list_member.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def make_default
    @question_list_member = QuestionListMember.find(params[:question_list_member_id])

    raise SecurityTransgression unless present_user.can_update?(@question_list_member)

    respond_to do |format|
      if @question_list_member.make_default!
        format.html { redirect_to question_lists_path }
      else
        format.json { render :json => @question_list_member.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
protected

  def get_question_list
    @question_list = params[:question_list_id].nil? ? nil : QuestionList.find(params[:question_list_id])
  end

end
