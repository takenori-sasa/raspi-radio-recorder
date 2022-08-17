module Api
  module V1
    class ProgramsController < ApplicationController
      include Raspio
      before_action :set_program, only: [:show, :update, :destroy]
      before_action :programs?, only: [:index]

      def index
        programs = Program.where(search_params).order(from: :asc)
        render json: { status: 'SUCCESS', message: 'Loaded programs', data: programs }
      rescue StandardError => e
        Rails.logger.error(e.full_message)
        render json: { status: 'ERROR', data: e.full_message }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the program', data: @program }
      end

      def create(date)
        Program.add(date)
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
        @program = Program.find(params[:id])
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
        dates.each do |d|
          Program.add(d) if Program.where(date: d).count.zero?
        rescue StandardError => e
          Rails.logger.error(e.full_message)
          render json: { status: 'ERROR', data: e.full_message }
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
