#!/usr/bin/env escript
main(_) ->
    Tests = [folsom, estatist],
    MetricTypes = %[histogram, meter, counter],
        [all],
    F =
        fun(Test) ->
            F1 = fun(MetricType) ->
                {Time, ok} = timer:tc(fun() -> test(Test, MetricType, 100000) end),
                io:format("~p ~p: ~p", [Test, MetricType, Time])
            end,
            lists:foreach(F1, MetricTypes)
        end,
    lists:foreach(F, Tests).


test(folsom, MetricType, N) ->
    folsom:start(),
    case MetricType of
        histogram ->
            folsom_metrics:new_histogram(test),
            [folsom_metrics:notify({test, X}) || X <- lists:seq(0, N)],
            folsom_metrics:delete_metric(test);
        meter ->
            folsom_metrics:new_meter(test),
            [folsom_metrics:notify({test, X}) || X <- lists:seq(0, N)],
            folsom_metrics:delete_metric(test);
        counter ->
            folsom_metrics:new_counter(test),
            [folsom_metrics:notify({test, X}) || X <- lists:seq(0, N)],
            folsom_metrics:delete_metric(test);
        all ->
            Metrics = [test1, test2, test3],
            folsom_metrics:new_counter(test1),
            folsom_metrics:new_meter(test2),
            folsom_metrics:new_histogram(test3),
            [[folsom_metrics:notify({M, X}) || M <- Metrics] || X <- lists:seq(0, N)],
            [folsom_metrics:delete_metric(M) || M <- Metrics]
    end,
    folsom:stop();

test(estatist, MetricType, N) ->
    estatist:start(),
    case MetricType of
        histogram ->
            estatist:add_metric(test, var, [histogram]),
            [estatist_core:update(test, X) || X <- lists:seq(0, N)];
        meter ->
            estatist:add_metric(test, var, [meter]),
            [estatist_core:update(test, X) || X <- lists:seq(0, N)];
        counter ->
            estatist:add_metric(test, var, [meter]),
            [estatist_core:update(test, X) || X <- lists:seq(0, N)];
        all ->
            estatist:add_metric(test, var, [histogram, meter, counter]),
            [estatist_core:update(test, X) || X <- lists:seq(0, N)]
    end,
    estatist:delete_metric(test),
    estatist:stop().
