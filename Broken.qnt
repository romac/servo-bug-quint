// -*- mode: Bluespec; -*-

// https://medium.com/@polyglot_factotum/re-fixing-servos-event-loop-e00bdf267385

module Broken {
  import common.* from "./common" 

  // Types

  type State = {
    queue: TaskId -> bool,
    taskQueued: bool,
  }

  // Variables

  var state: State

  // Actions

  action init = all {
    state' = {
      queue: Pipeline.map(id => (id, false)).setToMap(),
      taskQueued: false,
    },

    recordLastAction("init", -1),
  }

  action queueTask(p: TaskId): bool = all {
    require(state.taskQueued == false),

    state' = state
      .with("queue", state.queue.set(p, true))
      .with("taskQueued", true),

    recordLastAction("queueTask", p),
  }

  action runTask(p: TaskId): bool = all {
    require(state.queue.get(p) == true),

    state' = state
      .with("queue", state.queue.set(p, false))
      .with("taskQueued", false),

    recordLastAction("runTask", p),
  }

  action closePipeline(p: TaskId): bool = all {
    state' = state
      .with("queue", state.queue.set(p, false)),

    recordLastAction("closePipeline", p),
  }

  action step: bool = {
    nondet p = oneOf(Pipeline)
    any {
      queueTask(p),
      runTask(p),
      closePipeline(p),
    }
  }

  // Invariants

  pure def queuedTaskRuns: bool = {
    state.taskQueued implies Pipeline.exists(id => state.queue.get(id))
  }

}

module MC4 {
  import Broken(N = 4).*
}

