#!/usr/bin/env sysbench
-- Copyright (C) 2006-2017 Alexey Kopytov <akopytov@gmail.com>

-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

-- ----------------------------------------------------------------------
-- Index insertion benchmark
-- ----------------------------------------------------------------------

require("iibench_common")


function prepare_statements()
  -- first thread inserts, other selects
   if sysbench.opt.threads > 1
   then
      prepare_market_queries()
      prepare_register_queries()
      prepare_pdc_queries()
   end
   prepare_thread_groups()
end

function main_event()
   execute_inserts()

   check_reconnect()
end

function event()
   local query_type = sysbench.rand.uniform(1,3)
   local switch = {
      [1] = execute_market_queries,
      [2] = execute_pdc_queries,
      [3] = execute_register_queries
   }
   switch[query_type]()


   check_reconnect()
end


function prepare_thread_groups()
   thread_groups = {
      {
         event = main_event,
         thread_amount = sysbench.opt.insert_threads,
         rate = sysbench.opt.insert_rate,
         rate_controller = default_rate_controller
      },
      {
         event = event,
         thread_amount = sysbench.opt.select_threads,                -- 0 all other threads
         rate = sysbench.opt.select_rate,
         rate_controller = default_rate_controller
      }
   }
end