module Web
  class ChangeImagesController < ApplicationWebController
    skip_before_action :verify_authenticity_token, only: [:update_image, :update_image_question]

    before_action :http_authenticate

    def question_images
      @questionnaire = Questionnaire.last
      @questions = @questionnaire.questions
      render "change_images/index"

    end

    def option_images
      @questionnaire = Questionnaire.last
      @options = Option.all
      render "change_images/options"

    end

    def update_image
      @question = Question.find(params[:id])
      if @question.update(question_params)
        redirect_to question_images_web_change_images_path
      else
        redirect_to question_images_web_change_images_path
      end
    end

    def update_image_question
      @option = Option.find(params[:id])
      if @option.update(option_params)
        redirect_to option_images_web_change_images_path
      else
        redirect_to option_images_web_change_images_path
      end
    end


    private

    def question_params
      params.require(:question).permit(:image)
    end

    def option_params
      params.require(:option).permit(:image)
    end
  end
end
