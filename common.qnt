// -*- mode: Bluespec; -*-

module common {

 // Utilities

  pure def add(s: Set[a], x: a): Set[a] = s.union(Set(x))

  pure def require(cond: bool): bool = cond

  // Constants

  const N: int

  pure val Pipeline: Set[TaskId] = 0.to(N - 1)

  // Types

  type TaskId = int

  type Action = {
    name: str,
    taskId: TaskId,
  }

  // Traces

  var lastAction: Action

  action recordLastAction(name: str, taskId: TaskId): bool = {
    lastAction' = { name: name, taskId: taskId }
  }
  
}

