module Api
  module V1
    class ProgramsController < ApplicationController
      before_action :set_program, only: [:show, :update, :destroy]
      before_action :programs?, only: [:index]

      def index
        programs = Raspio::Program.where(search_params).order(from: :asc)
        render json: { status: 'SUCCESS', message: 'Loaded programs', data: programs }
      rescue StandardError => e
        Rails.logger.error(e.full_message)
        render json: { status: 'ERROR', data: e.full_message }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the program', data: @program }
      end

      def create(date)
        Raspio::Program.add(date)
      rescue StandardError => e
        logger.error(e)
        render json: { status: 'ERROR', data: e }
        raise ActiveRecord::Rollback
      end

      def destroy
        @program.destroy
        render json: { status: 'SUCCESS', message: 'Deleted the program', data: @program }
      end

      def update
        if @program.update(program_params)
          render json: { status: 'SUCCESS', message: 'Updated the program', data: @program }
        else
          render json: { status: 'SUCCESS', message: 'Not updated', data: @program.errors }
        end
      end

      private

      def set_program
        @program = Raspio::Program.find(params[:id])
      end

      def program_params
        params.require(:program).permit(:title, :date)
      end

      def search_params
        params.require(:program).permit(date: [])
      end

      def programs?
        # params
        # :date [string]
        dates = search_params[:date]
        dates.each do |date|
          Raspio::Program.add(date) unless Raspio::Program.date_cache?(date)
        rescue StandardError => e
          Raspio::Program.delete_cache(date)
          Rails.logger.error(e.full_message)
          # render json: { status: 'ERROR', message: 'Time-Table Not Found', data: { date:, error_message: e.message } }
        end
      end
    end
  end
end
