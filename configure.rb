# frozen_string_literal: true
require "digest"
require "json"
require "tty-prompt"
require "http"
require_relative "console"

class PEDWizard
  def configure
    prompt = TTY::Prompt.new
    exos = Dir.glob("./exos/*.exo")

    answers = {
      background: "",
      jacket: "",
      assets: "",
      movie: "",
      data: File.expand_path("./dist/#{@chart_id}/data.ped").gsub("/", "\\\\\\\\"),
      ap: true,
      scale: 1,
    }
    CPuts.info "ファイルの設定を行います。パスを入力して下さい。"
    CPuts.warn "パスの両端の\"は取り除かれます。"

    answers[:background] = prompt.ask("背景ファイル（省略で自動生成）:") || download_background
    answers[:jacket] = prompt.ask("ジャケット（省略でダウンロード）:") || download_jacket
    answers[:assets] = prompt.ask("assetsフォルダ（省略でこのフォルダのassets）:") || File.expand_path("./assets")
    answers[:movie] = prompt.ask("プレイ動画:") do |q|
      q.validate ->(value) { File.exist?(process_path(value)) }, "プレイ動画が見付かりません。"
    end
    answers[:ap] = prompt.yes?("AP時のコンボ表示にしますか？").to_s
    answers[:scale] = calc_scale(answers[:jacket]).to_s

    exos.each do |exo|
      contents = File.read(exo, encoding: Encoding::SJIS)
      answers.each do |key, value|
        contents.gsub!("!!#{key}!!", process_path(value))
      end
      File.write(exo.sub("exos", "dist/#{@chart_id}"), contents, encoding: Encoding::SJIS)
    end

    content = File.read("./dist/#{@chart_id}/data.tmp.ped")
    answers.each do |key, value|
      content.gsub!("!!#{key}!!", process_path(value))
    end

    CPuts.success "ファイルの設定が完了しました。"
    File.write("./dist/#{@chart_id}/data.ped", content)
  end

  def process_path(value)
    value
      .gsub("/", "\\")
      .gsub("\\", "\\\\\\\\")
      .gsub(/^"|"$/, "")
      .gsub(/\\$/, "")
      .encode("SHIFT_JIS")
  end

  def download_background
    print "\e[90m背景画像をダウンロードしています...\e[m"
    File.write(
      "./dist/#{@chart_id}/background.png",
      HTTP.get("https://image-gen.sevenc7c.com/generate/#{@chart_id}.png").body.to_s,
      mode: "wb",
    )
    puts "\e[92m 完了\e[m"
    File.expand_path("./dist/#{@chart_id}/background.png")
  end

  def download_jacket
    print "\e[90mジャケットをダウンロードしています...\e[m"
    data = JSON.parse(
      HTTP.get("https://servers.purplepalette.net/levels/#{@chart_id}").body,
      symbolize_names: true,
    )
    File.write(
      "./dist/#{@chart_id}/jacket.png",
      HTTP.get("https://servers.purplepalette.net" + data[:item][:cover][:url]).body.to_s,
      mode: "wb",
    )
    puts "\e[92m 完了\e[m"
    File.expand_path("./dist/#{@chart_id}/jacket.png")
  end
end
