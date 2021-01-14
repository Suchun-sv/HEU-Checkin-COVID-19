#!/usr/bin/env ruby
# frozen_string_literal: true

###
# 平安行动自动打卡
# 
# 请事先安装好 watir webdrivers 模块
# 
#   gem install watir headless webdrivers
# 
# 然后修改 20-21 行为自己的数据
# 
# Created on 2020-07-04 07:07
# @author: XYenon & Monst.x
###

require 'watir'
require 'webdrivers/chromedriver'

USERNAME = 'StudentNum'
PASSWORD = 'Password'

puts '========================='
Watir.default_timeout = 120
args = ['--headless', '--no-sandbox', '--ignore-certificate-errors', '--disable-dev-shm-usage', '--disable-translate', '--window-size=1920x1080']
browser = Watir::Browser.new :chrome, options: {args: args}
browser.goto 'http://ehome.hrbeu.edu.cn/'

def login(browser, username, password)
  browser.text_field(id: 'username').set username
  browser.text_field(id: 'password').set password
  browser.button(name: 'submit').click
end

# First login
login(browser, USERNAME, PASSWORD)
puts '[debug] Login ehome success...'

# Second login
browser.goto 'https://one.wvpn.hrbeu.edu.cn/infoplus/form/JKXXSB/start'
login(browser, USERNAME, PASSWORD)
puts '[debug] Login one success...'

# Wait for loading
browser.wait_until(timeout: 120, interval: 3) do |b|
  b.div(id: 'div_loader').style.include?('display: none;')
end
puts '[debug] Form loaded...'

# Select the checkbox
cb = browser.checkbox(id: 'V1_CTRL82')
cb.set unless cb.set?
puts '[debug] Checkbox checked...'

# Submit
browser.link(text: '确认填报').click
sleep 5
browser.button(text: '好').click
puts '[debug] Form Submitted...'
sleep 5
browser.button(text: '确定').click

# Check success
browser.refresh
browser.wait_until(timeout: 120, interval: 3) do |b|
  b.div(id: 'div_loader').style.include?('display: none;')
end
puts '[debug] ' + browser.div(id: 'title_content').text
if browser.div(id: 'title_content').text.include?('已完成')
  puts '[info] Checkin Success!'
else
  puts '[error] Checkin Fail!'
end
puts '[info] End at ' + Time.now.to_s + '.'
browser.close
puts '========================='