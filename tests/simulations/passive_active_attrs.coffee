###
1) clone the repo
2) npm install
3) coffee ./tests/math_samples.coffee

Current results at https://gist.github.com/lefnire/8049676
###

shared = require '../../script/index.coffee'
_ = require 'lodash'

id = shared.uuid()
user =
  stats: {class: 'warrior', buffs: {per:0,int:0,con:0,str:0}}
  party: quest: key:'evilsanta', progress: {up:0,down:0}
  preferences: automaticAllocation:false
  achievements:{}
  flags: levelDrops: {}
  items:
    eggs: {}
    hatchingPotions: {}
    food: {}
    quests:{}
    gear:
      equipped:
        weapon: 'weapon_warrior_4'
        armor:  'armor_warrior_4'
        shield: 'shield_warrior_4'
        head:   'head_warrior_4'
  habits: [
    shared.taskDefaults({id, value: 0})
  ]
  dailys: []
  todos: []
  rewards: []

shared.wrap(user)
s = user.stats
task = user.tasks[id]
party = [user]

console.log "\n\n================================================"
console.log "New Simulation"
console.log "================================================\n\n"

clearUser = (lvl=1) ->
  _.merge user.stats, {exp:0, gp:0, hp:50, lvl:lvl, str:lvl, con:lvl, per:lvl, int:lvl, mp: 100}
  _.merge s.buffs, {str:0,con:0,int:0,per:0}
  _.merge user.party.quest.progress, {up:0,down:0}
  user.items.lastDrop = {count:0}

_.each [1,25,50,75,99], (lvl) ->
  console.log "[LEVEL #{lvl}] (#{lvl} points in every attr)\n\n"
  _.each {red:-25,yellow:0,green:35}, (taskVal, color) ->
    console.log "[task.value = #{taskVal} (#{color})]"
    console.log "direction\texpΔ\t\thpΔ\tgpΔ\ttask.valΔ\ttask.valΔ bonus\t\tboss-hit"
    _.each ['up','down'], (direction) ->
      clearUser(lvl)
      b4 = {hp:s.hp, taskVal}
      task.value = taskVal
      task.type = 'daily' if direction is 'up'
      delta = user.ops.score params:{id, direction}
      console.log "#{if direction is 'up' then '↑' else '↓'}\t\t#{s.exp}/#{shared.tnl(s.lvl)}\t\t#{(b4.hp-s.hp).toFixed(1)}\t#{s.gp.toFixed(1)}\t#{delta.toFixed(1)}\t\t#{(task.value-b4.taskVal-delta).toFixed(1)}\t\t\t#{user.party.quest.progress.up.toFixed(1)}"

    str = '- [Wizard]'

    task.value = taskVal;clearUser(lvl)
    b4 = {taskVal}
    shared.content.spells.wizard.fireball.cast(user,task)
    str += "\tfireball(task.valΔ:#{(task.value-taskVal).toFixed(1)} exp:#{s.exp.toFixed(1)} bossHit:#{user.party.quest.progress.up.toFixed(2)})"

    task.value = taskVal;clearUser(lvl)
    _party = [user, {stats:{mp:0}}]
    shared.content.spells.wizard.mpheal.cast(user,_party)
    str += "\t| mpheal(mp:#{_party[1].stats.mp})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.wizard.earth.cast(user,party)
    str += "\t\t\t\t| earth(buffs.int:#{s.buffs.int})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.wizard.frost.cast(user,{})
    str += "\t\t\t| frost(N/A)"

    console.log str
    str = '- [Warrior]'

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.warrior.smash.cast(user,task)
    b4 = {taskVal}
    str += "\tsmash(task.valΔ:#{(task.value-taskVal).toFixed(1)})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.warrior.defensiveStance.cast(user,{})
    str += "\t\t| defensiveStance(buffs.con:#{s.buffs.con})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.warrior.valorousPresence.cast(user,party)
    str += "\t\t\t| valorousPresence(buffs.str:#{s.buffs.str})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.warrior.intimidate.cast(user,party)
    str += "\t\t| intimidate(buffs.con:#{s.buffs.con})"

    console.log str
    str = '- [Rogue]'

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.rogue.pickPocket.cast(user,task)
    str += "\tpickPocket(gp:#{s.gp.toFixed(1)})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.rogue.backStab.cast(user,task)
    b4 = {taskVal}
    str += "\t\t| backStab(task.valΔ:#{(task.value-b4.taskVal).toFixed(1)} exp:#{s.exp.toFixed(1)} gp:#{s.gp.toFixed(1)})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.rogue.toolsOfTrade.cast(user,party)
    str += "\t| toolsOfTrade(buffs.per:#{s.buffs.per})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.rogue.stealth.cast(user,{})
    str += "\t\t| stealth(avoiding #{user.stats.buffs.stealth} tasks)"

    console.log str
    str = '- [Healer]'

    task.value = taskVal;clearUser(lvl)
    s.hp=0
    shared.content.spells.healer.heal.cast(user,{})
    str += "\theal(hp:#{s.hp.toFixed(1)})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.healer.brightness.cast(user,{})
    b4 = {taskVal}
    str += "\t\t\t| brightness(task.valΔ:#{(task.value-b4.taskVal).toFixed(1)})"

    task.value = taskVal;clearUser(lvl)
    shared.content.spells.healer.protectAura.cast(user,party)
    str += "\t\t\t| protectAura(buffs.con:#{s.buffs.con})"

    task.value = taskVal;clearUser(lvl)
    s.hp=0
    shared.content.spells.healer.heallAll.cast(user,party)
    str += "\t\t| heallAll(hp:#{s.hp.toFixed(1)})"

    console.log str
    console.log '\n'


  console.log '------------------------------------------------------------'



