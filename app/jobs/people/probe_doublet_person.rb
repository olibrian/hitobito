# encoding: utf-8

class People::ProbeDoublettes < BaseJob
  run_every 1.day

  def perform
    People::DoubletteChecker.check
  end

end
