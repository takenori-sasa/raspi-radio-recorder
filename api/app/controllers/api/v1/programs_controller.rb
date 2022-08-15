require 'uri'
require 'net/http'
require 'base64'
require 'tempfile'
module Api
  module V1
    class ProgramsController < ApplicationController
      include Raspio
      before_action :set_program, only: [:show, :update, :destroy]

      def index
        programs = Program.order(created_at: :desc)
        render json: { status: 'SUCCESS', message: 'Loaded programs', data: programs }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the program', data: @program }
      end

      def create
        program = Program.new(program_params)
        if program.save
          render json: { status: 'SUCCESS', data: program }
        else
          render json: { status: 'ERROR', data: program.errors }
        end
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
        params.require(:program).permit(:title)
      end
    end
  end
end
