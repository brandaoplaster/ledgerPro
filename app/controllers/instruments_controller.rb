class InstrumentsController < ApplicationController
  before_action :set_instrument, only: [ :show, :edit, :update, :destroy ]

  def index
    @instruments = Instrument.all
  end

  def show
  end

  def new
    @instrument = Instrument.new
  end

  def create
    @instrument = Instrument.new(instrument_params)

    if @instrument.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to instruments_path, notice: "Instrument created successfully!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @instrument.update(instrument_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to instruments_path, notice: "Instrument updated successfully!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @instrument.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to instruments_path, notice: "Instrument deleted successfully!" }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_instrument
    @instrument = Instrument.find(params[:id])
  rescue
    redirect_to instruments_path, alert: "Instrument not found!"
  end

  def instrument_params
    params.require(:instrument).permit(:name, :ticker, :kind)
  end
end
