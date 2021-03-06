require 'action_controller/parameters'
require 'action_controller/parametters'
params = ActionControlelr::Parameters.new({
		person:{
			name: 'France',
			age: 22,
			role: 'admin'
		}
	})

permitted = params.require(:person).permit(:name,:age) # 只传进了name，age

permitted  # => {"name"=>"France", "age"=>22}
permited.class # => ActionController::Parameters
permit!
@user.update_attributes(params[:user].permit!)
config.always_permitted_parameters = %( controller action format )
permitted.permitted? # => true

@user.attributes # 可以认为是一个hash,里面的key是数据库对应的字段名

如果包含未被允许更新的字段，会抛ForbiddenAttributesError错误
params 实际上是Parameter实例对象，我们可以对它的属性进行读、写操作

params == request.parameters # => true
并不表明它们是完全等价的 后者是ActiveSupport::HashWithIndifferentAccess实例对象
这个对象的值是什么？ 表单数据或传递过来的，加上:controller 和 :action

send_data send_file是类似的 但 send_data 可以发送的是数据 send_file 只能先有文件，才能发送
一般 动态生成的一次性内容 用send_data 比较好，纯文件或内容可提供多次下载的 用send_file 比较好
另外 实际项目里 静态资源还可以通过web服务器(Nginx/Apache)发送，应用只要提供URL即可。静态资源的URL
此时，仍然可以和原来一样调用send_file方法但真正返回数据的时候，web服务器会自动忽略掉应用服务器的response

config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
config.actino_dispatch.x_sendfile_header = "X-Accel-Redirect"
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for Nginx
flash.alert = "you must be logged in"
flash.notice = "post successfully created"
flash.alert
flash.notice

add_flash_types :warning, :success, :danger

alert notice 默认已经使用add_flash_types

flash消息的生命周期可到下一个action 所以通常搭配redirect_to使用
flash.now[]消息的生命周期仅限于本action，所以 通常搭配render使用
helpers
本质是ActionView::Base的实例对象
ApplicationController.helpers.class
all_helpers_from_path
helper_attr
modules_for_helpers
config.action_controller.include_all_helpers = false
cookies 本质上是 request.cookie_jar

Middleware是Action Dispatch实现的，而Metal增强组件是Action Controller实现的
Middleware是在请求进入Controller#action之前，而Metal增强组件是在请求进入Controller#action之后
Middleware需要的环境是 @env 作用的是app， 而Metal增强组件需要的环境是Controller和action，目的主要是对请求做处理，并相应
action接受请求并处理，最后渲染相应视图模板或重定向到另一个action
如果你想在所有controller处理之前做一些什么，你可以把它们写在ApplicationController里
config.action_controller.perform_caching = false
config.action_controller.perform_caching = true

cache
write_fragment read_fragment
cache_store

cache 'all_available_products', skip_digest: true
expire_fragment('all_available_products')

default_form_builder
class AdminForBuilder < ActionView::Helpers::default_form_builder
	def special_field(name)

	end

end

module Rails
  class Engine < Railtie
    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new
      @routes.append(&Proc.new) if block_given?
      @routes
    end
  end
end
Rails.application.routes

Rails.application.routes.draw do
  # block 内容
end

def draw(&block)
  eval_block(block)

  nil
end

def eval_block(block)

  mapper = Mapper.new(self)

  mapper.instance_exec(&block)
end

module ActionDispatch
  module Routing
    class Mapper
      def initialize(set)
        @set = set
        @scope = Scope.new({ :path_names => @set.resources_path_name})
        @concerns = {}
        @nesting = []
      end
    end
  end
end

require 'bundler/setup'

run Proc.new{ |env|
    if env["PATH_INFO"] == "/"
      [200, {"Content-Type" => "text/html"}, []]
    else
      [404, {"Content-Type" => "text/html"},[]]
    end
    }

require 'bundler/setup'
require 'action_dispatch'

routes = ActionDispatch::Routing::RouteSet.new
routes.draw do
  get '/' => 'mainpage#index'
  get '/page/:id' => 'mainpage#show'
end

class MainpageController
  def self.action(method)
    controller = self.new
    controller.method
  end
  def index(env)
    [200, {"Content-Type" => "text/html"},[]]
  end
  def show(env)
    [200, {"Content-Type" => "text/html"},[]]
  end
end

run routes


routes = ActionDispatch::Routing::RouteSet.new
routes.draw do
  get '/' => 'mainpage#index'
end

class MainpageController < ActionController::Metal
  def index
    self.response_body = ""
  end
  def show
    self.status = 404
    self.response_body = ""
  end
end

include AbstractController::Rendering
include ActionController::Rendering
include ActionController::ImplicitRender
include ActionView::Rendering

def render_to_body(*args)
  template = ERB.new File.read("#{params[:action]}.html.erb")
  template.result(binding)
end

run routes

# config.ru
# require 'bundler/setup'
# require 'action_dispatch'
# require 'action_view'
require 'action_controller'
routes = ActionDispatch::Routing::RouteSet.new
routes.draw do
  get '/' => 'mainpage#index'
  get '/page/:id' => 'mainpage#show'
end
class MainpageController < ActionController::Base
  prepend_view_path('app/views/')
  def index
    @local_var = 12345
  end
  def show
  end
end
use ActionDispatch::DebugExceptions
run routes

rackup config.ru 运行以上代码，默认在 http://localhost:9292/


Middleware 在路由转发之后，Controller#action接收之前，对环境和应用进行处理。
路由转发-》 middleware -》 controller#action


app应用 --> (Rack) --> 应用服务器 --> Web服务器 --> 外部世界;

Rack 提供了一个与Web服务器打交道最精简的接口，通过这个接口，我们应用很轻松的就能提供Web服务(接收Web请求，相应处理结果)。
上面的应用服务器就是对Rack的进一步封装
这个接口的条件是： 传递一个程序(你没看错，就是把一个程序当做参数，下文以app代替)


class YourRack
  def initialize app
    @app = app
  end
  def call env
    @app.call(env)
  end
end

ActionController#cookies 读写cookies数据
简单的cookie数据
浏览器关闭则删除
cookies[:user_name] = "david"
设置cookie数据的生命周期为一小时
cookies[:login] = { value: "XJ-122", expires: 1.hour.from_now}
# cookie 数据签名(用到secrets.secret_key_base), 防止用户篡改
# 可以使用 cookies.signed[:name] 获取这个签名后的数据
cookies.signed[:user_id] = current_user.id
# 设置一个永久cookie，默认生命周期是20年
cookies.permanent[:login] = "XJ-122"
# 你可以链式调用以上方法

include ActionDispatch::Http::Cache::Request
include ActionDispatch::Http::MimeNegotiation
include ActionDispatch::Http::Parameters
include ActionDispatch::Http::FilterParameters
include ActionDispatch::Http::URL

env = { "Content-Type" => "text/html"}
headers = ActionDispatch::Http::Headers.new(env)
headers["Content-Type"]
request.parameters 和 params 是不同的,params还包括了 path_parameters

Rails.application.config.filter_parameters += [:password]
config.filter_redirect << 'www.rubyonrails.org'
Rails.application.config.filter_redirect << 'www.rubyonrails.org'

require 'action_dispatch'
routes = ActionDispatch::Routing::RouteSet.new
routes.draw do
  get '/' => 'mainpage#index'
  get '/page/:id' => 'mainpage#show'
end

include Rails.application.routes.url_helpers
include Rails.application.routes.url_helpers
include Rails.application.routes.url_helpers

Routing::RouteSet::Dispatcher.new(defaults)


#在 Controller 里，除了实例变量，我们还可以有其它方法传递内容给 View，两者方式类似。不可用于实际项目

class BasicController < ActionController::Base

  # 1 只引入对应模块
  include ActionView::Context

  # 2 调用对应模块里的方法
  before_filter :_prepare_context

  def hello_world
    @value = "Hello World"
  end

  protected
  # 3 更改 view_context
  # 默认是 ActionView::Base 的实例对象

  def view_context
    self
  end

  # 在view里可以调用此方法

  def __controller_method__
    "controller context!"
  end
end

#下面 helper 分类，只是为了方便理清它们的结构。实际过程中，可交叉使用，能达
#到目的即可，并且直接写 HTML 也是允许的。
#"#{有的方法根据其参数，可归于多个分类。如：表单元素和通用元素(非表单元素)。
#"因为 Rails 背后会把所有 helper 方法(函数)都会被放进同一个 module 里，所以它们之间互相调用。

# <table>
# <% @items.each do |item| %>
#    <tr class="<%= cycle("odd", "even") -%>">
#      <td>item</td>
#    </tr>
#  <% end %>
# </table>
#

class Person
  include ActiveModel::Validations
  attr_accessor :name

  validates :name, title: true

  ActiveRecord::Base.class_eval do
    def self.validates_date_of(*attr_names)
      validates_with TitleValidator, _merge_attributes(attr_names)
    end
  end
end

cat = Cat.new(name: 'Gorby', status: 'yawning')
cat.assign_attributes(status: 'sleeping')
cat.attributes
#原理上它和直接赋值是一样的，用了元编程一个个属性直接赋值，只是对要传递的参数多了ForbiddenAttributesProtection

class Person
  include ActiveModel::AttributeMethods
  attribute_method_prefix 'clear_'
  attribute_method_suffix '_contrived?'
  attribute_method_affix prefix: 'reset_', suffix: '_to_default!'
  define_attribute_methods :name
end

# Strong Parameters 是黑名单，params在controller层面 permit后状态变成permitted进入白名单，只有permit属性才能进入我们系统

class Person
  include ActiveModel::ForbiddenAttributesProtection
end

serializable_hash
serializable_hash
serializable_hash

class Person
  extend ActiveModel::Callbacks
  define_model_callbacks :update
end

class Person < ActiveRecord::Base
  params = ActionController::Parameters.new(name: 'Bob')
  person.new(params) # => ActiveModel::ForbiddenAttributesError
  params.permit!
  Person.new(params) # => #<Person id: nil, name: "Bob">
end

#运用中间态，也就是Relation。每次查询并不是真正的查询（因为还没有走到SQL层面），而是保存一个中间状态，当你所有的查询条件都写完了，
#才进入SQL的层面。理论上，这些简单的查询最后都能组合成SQL语句。

# 延迟加载。我们在 Controller 里有一个查询语句，结果赋值给一个实例变量，原本
# 的意图是在 View 里显示的。某天需求更改了，我们不必再显示这个查询结果，但
# Controller 里我们忘记删除这部分的代码(这都能忘？)，结果每次都要做大量无用的
# 查询工作。引入中间状态后，就能起到延迟加载 的作用，不到最后的调用，不做
# SQL 查询(停留在 Ruby 层面)。
# 链式查询，效率高。
#这里部分是对多个对象的操作，对Relation的操作，不是查询操作。Relation是对象，到最后才会转为SQL语句

#对于要匹配的子串T来说，“abcdex”首字母“a”与后面的串“bcdex”中任意一个字符都不相等，也就是说，既然“a”不予自己后面
#子串中任何一个字符相等，那么对于图前五位字符分别相等，意味着子串T的首字符“a”不可能与S串的第2位到第5位的字符相等。在图。2、3、4、5的判断都是多余的。
#同样道理，在我们知道T串中首字符“a”与“T”中后面的字符均不相等的前提下，T串的“a”与S串后面的“c”、“d”、“e”
#也都可以在1之后就可以确定是不相等的，所以这个算法中2、3、4、5没有必要，只保留1、6即可。
#也就是说，对于在子串中有与首字符相等的字符，也是可以省略一部分不必要的判断步骤。
#既然i值不回溯，也就是不可以变小，那么要考虑的变化就是j值了。通过观察也可发现我们屡屡提到了T串的首字符与自身后面字符的比较，
#发现如果有相等字符，j值得变化就会不同。也就是说，这个j值的变化与主串其实没什么关系，关键就取决于T串的结构中是否有重复的问题






















