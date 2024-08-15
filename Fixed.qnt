// https://medium.com/@polyglot_factotum/re-fixing-servos-event-loop-e00bdf267385

module Fixed {
  import common.* from "./common"

  // Types

  type State = {
    queue: TaskId -> bool,
    taskQueued: TaskId -> bool,
    closed: Set[TaskId],
  }

  // Variables

  var state: State

  // Actions

  action init = all {
    state' = {
      queue: Pipeline.map(id => id -> false).setToMap(),
      taskQueued: Pipeline.map(id => id -> false).setToMap(),
      closed: Set(),
    },

    recordLastAction("init", -1),
  }

  action queueTask(p: TaskId): bool = all {
    require(state.closed.contains(p) == false),
    require(state.taskQueued.get(p) == false),

    state' = state
      .with("queue", state.queue.set(p, true))
      .with("taskQueued", state.taskQueued.set(p, true)),

    recordLastAction("queueTask", p),
  }

  action runTask(p: TaskId): bool = all {
    require(state.queue.get(p) == true),

    state' = state
      .with("queue", state.queue.set(p, false))
      .with("taskQueued", Pipeline.map(id => id -> false).setToMap()),

    recordLastAction("runTask", p),
  }

  action closePipeline(p: TaskId): bool = all {
    state' = state
      .with("queue", state.queue.set(p, false))
      .with("closed", state.closed.add(p)),

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
    Pipeline
      .exclude(state.closed)
      .forall(p => state.taskQueued.get(p) implies state.queue.get(p))
  }

}

module MC4 {
  import Fixed(N = 4).*
}

