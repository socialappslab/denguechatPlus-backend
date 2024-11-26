module Web
  class ChangeImagesController < ApplicationWebController
    skip_before_action :verify_authenticity_token, only: [:update_image]

    before_action :http_authenticate

    def question_images
      @questionnaire = Questionnaire.last
      @questions = @questionnaire.questions
      render "change_images/index"

    end

    def update_image
      @question = Question.find(params[:id])
      if @question.update(question_params)
        redirect_to question_images_web_change_images_path
      else
        redirect_to question_images_web_change_images_path
      end
    end


    private

    def question_params
      params.require(:question).permit(:image)
    end
  end
end
