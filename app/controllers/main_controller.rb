require 'csv'
class MainController < ApplicationController
  include MainHelper

  @@results = {}

  def home
    @data = flash[:data]
    @k = flash[:k]
    @l = flash[:l]
    @x = flash[:x]
    @inc = flash[:inc]
    @rep = flash[:rep]

    authenticity_token = flash[:authenticity_token]
    if authenticity_token != nil
      @randoms = @@results || {}

      if @randoms != nil && @randoms.values.length > 0
        @inverse_plot_data = @randoms[:inverse].map { |i| i.round(1) }.tally.map { |x, y| [x, y.to_f / @randoms[:inverse].length.to_f] }
        @neumann_plot_data = @randoms[:neumann].map { |i| i.round(1) }.tally.map { |x, y| [x, y.to_f / @randoms[:neumann].length.to_f] }
        @metro_plot_data = @randoms[:metropolis].map { |i| i.round(1) }.tally.map { |x, y| [x, y.to_f / @randoms[:metropolis].length.to_f] }
        @chart_data = [
          { name: 'Inverse', data: @inverse_plot_data },
          { name: 'Neumann', data: @neumann_plot_data },
          { name: 'Metropolis', data: @metro_plot_data },
        ]
      end

      return
    end

    @randoms = {}
    @data = []
  end

  def help
  end

  def set_data
    w = Weibull.new(params[:k].to_f, params[:l].to_f)
    probabilities = {}
    s1 = params[:x].to_f
    s2 = params[:x].to_f + params[:inc].to_f * params[:rep].to_f

    (s1..s2).step(params[:inc].to_f) do |x|
      probabilities[x.round 4] =(w.density_function x).round 4
    end

    r_count = params[:r_count].to_i

    @@results = {
      :inverse => (0..r_count-1).map {|| w.random_inverse },
      :neumann => (0..r_count-1).map {|| w.random_neumann },
      :metropolis => (0..r_count-1).map {|| w.random_metropolis }
    }

    redirect_to "/", flash: {
      :data => probabilities,
      :authenticity_token => params[:authenticity_token],
      :k => params[:k],
      :l => params[:l],
      :x => params[:x],
      :inc => params[:inc],
      :rep => params[:rep]
    }
  end

  def download
    rands = @@results
    csv = CSV.generate do |csv|
      csv << rands.keys
      rands.values[0].length.times do |i|
        csv << [rands.values[0][i], rands.values[1][i], rands.values[2][i]]
      end
    end
    respond_to do |format|
      format.csv { send_data csv, filename: "randoms.csv"}
    end
  end
end