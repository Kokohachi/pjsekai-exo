@echo off
DEL /Q /F /S "data\*" > nul
TYPE nul > data\.gitkeep
ruby level_data.rb
ruby calc_score.rb
ruby pack.rb
ruby configure.rb
pause