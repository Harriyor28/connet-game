/// Embedded offline level definitions for the Phase 1 prototype.
class PhaseOneLevels {
  static const List<Map<String, dynamic>> all = [
    {
      'id': 'easy_001', 'name': 'First Link', 'difficulty': 'easy', 'world': 'neon_lab', 'levelNumber': 1,
      'nodes': [
        {'id': 'n1', 'x': .20, 'y': .28, 'z': .10}, {'id': 'n2', 'x': .50, 'y': .18, 'z': .02}, {'id': 'n3', 'x': .80, 'y': .30, 'z': -.08},
        {'id': 'n4', 'x': .62, 'y': .72, 'z': -.02}, {'id': 'n5', 'x': .32, 'y': .72, 'z': .08}, {'id': 'n6', 'x': .50, 'y': .48, 'z': .16},
        {'id': 'n7', 'x': .14, 'y': .52, 'z': -.12}, {'id': 'n8', 'x': .86, 'y': .54, 'z': .12}, {'id': 'n9', 'x': .50, 'y': .88, 'z': -.10},
      ],
      'requiredConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n2', 'to': 'n6'}, {'from': 'n6', 'to': 'n5'}, {'from': 'n5', 'to': 'n4'}],
      'allowedConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n2', 'to': 'n6'}, {'from': 'n6', 'to': 'n5'}, {'from': 'n5', 'to': 'n4'}],
      'targetMoves': 4, 'targetTime': 30, 'stars': {'one': {'maxMoves': 6}, 'two': {'maxMoves': 5}, 'three': {'maxMoves': 4}},
    },
    {
      'id': 'easy_002', 'name': 'Six Step', 'difficulty': 'easy', 'world': 'neon_lab', 'levelNumber': 2,
      'nodes': [
        {'id': 'n1', 'x': .18, 'y': .22, 'z': -.10}, {'id': 'n2', 'x': .42, 'y': .34, 'z': .12}, {'id': 'n3', 'x': .68, 'y': .20, 'z': -.04},
        {'id': 'n4', 'x': .80, 'y': .58, 'z': .10}, {'id': 'n5', 'x': .52, 'y': .78, 'z': -.12}, {'id': 'n6', 'x': .22, 'y': .62, 'z': .06},
        {'id': 'n7', 'x': .50, 'y': .50, 'z': .18}, {'id': 'n8', 'x': .10, 'y': .40, 'z': -.06}, {'id': 'n9', 'x': .90, 'y': .36, 'z': .02},
      ],
      'requiredConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n2', 'to': 'n3'}, {'from': 'n3', 'to': 'n4'}, {'from': 'n4', 'to': 'n5'}, {'from': 'n5', 'to': 'n6'}],
      'allowedConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n2', 'to': 'n3'}, {'from': 'n3', 'to': 'n4'}, {'from': 'n4', 'to': 'n5'}, {'from': 'n5', 'to': 'n6'}, {'from': 'n1', 'to': 'n3'}, {'from': 'n2', 'to': 'n4'}],
      'targetMoves': 5, 'targetTime': 45, 'stars': {'one': {'maxMoves': 8}, 'two': {'maxMoves': 6}, 'three': {'maxMoves': 5}},
    },
    {
      'id': 'easy_003', 'name': 'Star Path', 'difficulty': 'easy', 'world': 'neon_lab', 'levelNumber': 3,
      'nodes': [
        {'id': 'n1', 'x': .50, 'y': .12, 'z': .10}, {'id': 'n2', 'x': .82, 'y': .40, 'z': -.08}, {'id': 'n3', 'x': .68, 'y': .78, 'z': .05},
        {'id': 'n4', 'x': .32, 'y': .78, 'z': -.12}, {'id': 'n5', 'x': .18, 'y': .40, 'z': .02}, {'id': 'n6', 'x': .50, 'y': .38, 'z': .18},
        {'id': 'n7', 'x': .50, 'y': .60, 'z': -.18}, {'id': 'n8', 'x': .34, 'y': .42, 'z': .06}, {'id': 'n9', 'x': .66, 'y': .42, 'z': -.04},
      ],
      'requiredConnections': [{'from': 'n1', 'to': 'n3'}, {'from': 'n3', 'to': 'n5'}, {'from': 'n5', 'to': 'n2'}, {'from': 'n2', 'to': 'n4'}, {'from': 'n4', 'to': 'n1'}],
      'allowedConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n1', 'to': 'n3'}, {'from': 'n1', 'to': 'n4'}, {'from': 'n1', 'to': 'n5'}, {'from': 'n2', 'to': 'n3'}, {'from': 'n2', 'to': 'n4'}, {'from': 'n2', 'to': 'n5'}, {'from': 'n3', 'to': 'n4'}, {'from': 'n3', 'to': 'n5'}, {'from': 'n4', 'to': 'n5'}],
      'targetMoves': 5, 'targetTime': 60, 'stars': {'one': {'maxMoves': 10}, 'two': {'maxMoves': 7}, 'three': {'maxMoves': 5}},
    },
    {
      'id': 'easy_004', 'name': 'Branch Point', 'difficulty': 'easy', 'world': 'neon_lab', 'levelNumber': 4,
      'nodes': [
        {'id': 'n1', 'x': .50, 'y': .50, 'z': .22}, {'id': 'n2', 'x': .18, 'y': .22, 'z': -.10}, {'id': 'n3', 'x': .82, 'y': .22, 'z': .02},
        {'id': 'n4', 'x': .18, 'y': .78, 'z': .08}, {'id': 'n5', 'x': .82, 'y': .78, 'z': -.12}, {'id': 'n6', 'x': .50, 'y': .14, 'z': -.04},
        {'id': 'n7', 'x': .50, 'y': .86, 'z': .04}, {'id': 'n8', 'x': .12, 'y': .50, 'z': -.06}, {'id': 'n9', 'x': .88, 'y': .50, 'z': .12}, {'id': 'n10', 'x': .33, 'y': .50, 'z': -.02},
      ],
      'requiredConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n1', 'to': 'n3'}, {'from': 'n1', 'to': 'n4'}, {'from': 'n1', 'to': 'n5'}, {'from': 'n1', 'to': 'n6'}],
      'allowedConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n1', 'to': 'n3'}, {'from': 'n1', 'to': 'n4'}, {'from': 'n1', 'to': 'n5'}, {'from': 'n1', 'to': 'n6'}, {'from': 'n1', 'to': 'n7'}, {'from': 'n1', 'to': 'n8'}, {'from': 'n1', 'to': 'n9'}],
      'targetMoves': 5, 'targetTime': 75, 'stars': {'one': {'maxMoves': 9}, 'two': {'maxMoves': 7}, 'three': {'maxMoves': 5}},
    },
    {
      'id': 'easy_005', 'name': 'Deep Circuit', 'difficulty': 'easy', 'world': 'neon_lab', 'levelNumber': 5,
      'nodes': [
        {'id': 'n1', 'x': .15, 'y': .20, 'z': -.12}, {'id': 'n2', 'x': .38, 'y': .13, 'z': .08}, {'id': 'n3', 'x': .66, 'y': .18, 'z': .18}, {'id': 'n4', 'x': .86, 'y': .40, 'z': -.04},
        {'id': 'n5', 'x': .74, 'y': .72, 'z': .10}, {'id': 'n6', 'x': .50, 'y': .86, 'z': -.14}, {'id': 'n7', 'x': .25, 'y': .76, 'z': .04}, {'id': 'n8', 'x': .12, 'y': .50, 'z': .14},
        {'id': 'n9', 'x': .50, 'y': .50, 'z': .22}, {'id': 'n10', 'x': .34, 'y': .37, 'z': -.08}, {'id': 'n11', 'x': .67, 'y': .38, 'z': -.10}, {'id': 'n12', 'x': .50, 'y': .66, 'z': .06},
      ],
      'requiredConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n2', 'to': 'n3'}, {'from': 'n3', 'to': 'n4'}, {'from': 'n4', 'to': 'n5'}, {'from': 'n5', 'to': 'n6'}, {'from': 'n6', 'to': 'n7'}, {'from': 'n7', 'to': 'n8'}, {'from': 'n8', 'to': 'n1'}],
      'allowedConnections': [{'from': 'n1', 'to': 'n2'}, {'from': 'n2', 'to': 'n3'}, {'from': 'n3', 'to': 'n4'}, {'from': 'n4', 'to': 'n5'}, {'from': 'n5', 'to': 'n6'}, {'from': 'n6', 'to': 'n7'}, {'from': 'n7', 'to': 'n8'}, {'from': 'n8', 'to': 'n1'}, {'from': 'n1', 'to': 'n9'}, {'from': 'n9', 'to': 'n5'}, {'from': 'n2', 'to': 'n10'}, {'from': 'n3', 'to': 'n11'}, {'from': 'n6', 'to': 'n12'}],
      'targetMoves': 8, 'targetTime': 90, 'stars': {'one': {'maxMoves': 13}, 'two': {'maxMoves': 10}, 'three': {'maxMoves': 8}},
    },
  ];
}
