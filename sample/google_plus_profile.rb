# Original version is for GroovyFX by @kazuchika
# https://gist.github.com/1341142

require File.expand_path('./utils', File.dirname(__FILE__))
require 'json'
require 'httpclient'

java_import 'javafx.geometry.VPos'
java_import 'javafx.scene.Group'
java_import 'javafx.scene.Scene'
java_import 'javafx.stage.Stage'
java_import 'javafx.scene.effect.Reflection'
java_import 'javafx.scene.effect.Bloom'
java_import 'javafx.animation.Interpolator'
java_import 'javafx.animation.RotateTransition'
java_import 'javafx.scene.image.Image'
java_import 'javafx.scene.image.ImageView'
java_import 'javafx.scene.paint.Color'
java_import 'javafx.scene.text.Font'
java_import 'javafx.scene.text.Text'
java_import 'javafx.util.Duration'

key = '<YOUR Google+ API KEY HERE>'
uid = 115625967573239196767 # user ID
url = "https://www.googleapis.com/plus/v1/people/#{uid}?key=#{key}"

class GooglePlusProfileApp
  include Utils

  DEFAULT_IMAGE_URL = 'http://cdn.mamapop.com/wp-content/uploads/2011/09/fuuuu-rage-guy1.png'

  def initialize(url)
    @json = JSON.parse(HTTPClient.get(url).body)
  end

  def start(stage)
    image_url = @json['image']['url'] || DEFAULT_IMAGE_URL
    display_name = @json['displayName'] || 'Unknown'
    tagline = @json['tagline'] || '(emtpy)'

    root = build(Group) {
      children <<
        build(ImageView,
              :x => 20, :y => 40,
              :image => Image.new(image_url, 200, 200, false, false),
              :effect => build(Reflection, :fraction => 0.25)) {
          t = build(RotateTransition,
                    :node => self, :duration => Duration.millis(1000),
                    :from_angle => 0, :to_angle => 360,
                    :interpolator => Interpolator::EASE_OUT)
          self.on_mouse_clicked = proc { t.play }
        }
      children <<
        build(Text,
              :text => display_name,
              :x => 240, :y => 60, :fill => Color::WHITE,
              :font => Font.new(32), :text_origin => VPos::TOP,
              :effect => Bloom.new)
      children <<
        build(Text,
              :text => tagline,
              :x => 240, :y => 120, :fill => Color::WHITE,
              :font => Font.new(16), :text_origin => VPos::TOP)
    }

    with(stage,
         :width => 640, :height => 380, :title => 'Profile',
         :scene => build(Scene, root, :fill => Color::BLACK)
        ).show
  end
end

JRubyFX.start(GooglePlusProfileApp.new(url))
