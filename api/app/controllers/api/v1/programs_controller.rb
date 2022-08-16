require 'pry'
module Api
  module V1
    class ProgramsController < ApplicationController
      include Raspio
      before_action :set_program, only: [:show, :update, :destroy]
      # before_action :make_time_table, only: [:show, :index]

      def index(date = [Time.zone.today])
        # search_params[:date].map { |d| d.is_a?(String) ? Date.parse(d) : d }
        # date.each do |d|
        #   d = Date.parse(d) if d.is_a?(String)
        # end
        # todo Strongパラメータに対応してクエリでも検索できるようにする
        create(date) if Program.where(date:).count.zero?
        programs = Program.where(date:).order(created_at: :desc)
        render json: { status: 'SUCCESS', message: 'Loaded programs', data: programs }
      end

      def show(date = [Time.zone.today])
        create(date) if Program.where(date:).count.zero?
        render json: { status: 'SUCCESS', message: 'Loaded the program', data: @program }
      end

      def create(date)
        Program::TimeTable.add(date)
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
        pparams = params.require(:program).permit(:date)
        pparams[:date].map! { |d| Date.parse(d) }
        pparams
      end
    end
  end
end
