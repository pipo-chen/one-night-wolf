# one-night-wolf
一夜狼 online 
初阶版本：
  1. 按照发言顺序，分析每个人暴露的信息，目前的处理方式是统一整合成最终发言态。
  2. 会存在死局，因为伪装者可以跟其他玩家发言内容一模一样，真假只能从别的玩家发言中进行推导。正常现象，死局是别的玩家都与双方无交集
  3. 狼会从公共池中找牌伪装自己
    - 狼要推测是否有捣蛋鬼或者强盗有换到自己的牌，
      捣蛋鬼极有可能
      强盗暴露性几乎为 0
      
  4. 爪牙就会随机从在场玩家身份中随机找牌伪装
   爪牙伪装玩法：
    - 此处考虑，狼跟爪牙同时伪装成守夜人 人机游戏无法破解，真实场景下只靠演技。
      但是这样暴露风险概率对狼来说其实是提升的
    - 伪装成捣蛋鬼，万一交换的是一张失眠者的牌 或者 场上存在真正的捣蛋鬼
    - 伪装成强盗
    - 伪装成失眠者
    - 伪装成预言家

好人玩法：
    常规态，实话实说
    - 如果强盗换到狼牌，调整成伪装策略
    - 如果失眠者醒来看到狼牌，调整成伪装策略
    
  之后高阶：
    跳身份 炸
    