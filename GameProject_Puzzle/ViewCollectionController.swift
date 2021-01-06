//
//  ViewCollectionController.swift
//  GameProject_Puzzle
//
//  Created by Ihor on 05.01.2021.
//

import UIKit

private let reuseIdentifier = "cell"

class ViewCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var puzzle = [Puzzle(title: "Pikachu", resImages: ["pikachuLeftFace","pikachuRightFace","pikachuLeftBody","pikachuRightBody"]),Puzzle(title: "Charuzard", resImages: ["charuzardLeftWing","charuzardNeck","charuzardRightWing","charuzardFace","charuzardBody","charuzardRightHand","charuzardTailEnd","charuzardTail","charuzardRightLeg"])]
    var index: Int = 0
    var gameTimer: Timer?
    var hintImageTimer: Timer?
    var hintImage = UIImageView()
    
    var counter = 0
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBAction func startButtonTouched(_ sender: UIButton) {
        runGame()
    }
    
    @objc func runGame () {
        self.collectionView.dragInteractionEnabled = true
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameEnd), userInfo: nil, repeats: true)
        startButton.isEnabled = false
    }
    
    @objc func gameEnd() {
        if counter >= 60 {
            Alert.showGameOverPuzzleAlert(on: self)
            clearTimer()
        } else {
            counter+=1
            timerLabel.text = "Left \(60 - counter) seconds"
        }
    }
    
    @objc func clearTimer() {
        counter = 0
        gameTimer?.invalidate()
        startButton.isEnabled = true
        restartButton.isEnabled = true
        timerLabel.text = "Finished"
    }
    
    @IBAction func hintButtonTouched(_ sender: UIButton) {
      showHint()
    }
    
    @objc func checkGameState() {
        if !collectionView.dragInteractionEnabled {
            Alert.showStartGameAlert(on:self)
        }
    }
    
    @objc func showHint() {
        hintImage.image = UIImage(named: puzzle[index].title)
        hintImage.contentMode = .scaleAspectFit
        hintImage.frame = self.view.frame
        self.view.addSubview(hintImage)
        self.collectionView.isHidden = true
        self.view.bringSubviewToFront(hintImage)
        hintImageTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(removeHint), userInfo: nil, repeats: false)
    }
    
    @objc func removeHint() {
        self.view.sendSubviewToBack(hintImage)
        self.collectionView.isHidden = false
    }
    
    
    @IBAction func restartButtonTouched(_ sender: UIButton) {
        restartButton.isEnabled = false
        while puzzle[index].unresolvedImages == puzzle[index].resultImages   {
            puzzle[index].unresolvedImages = puzzle[index].unresolvedImages.shuffled()
        }
        self.collectionView.reloadData()
        gameTimer?.invalidate()
        runGame()
    }
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        index+=1
        if index > puzzle.count - 1 {
            index = 0
        }
        self.collectionView.reloadData()
        self.collectionView.dragInteractionEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
//        view.addSubview(collectionView)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier:
                            reuseIdentifier)
        collectionView.dragInteractionEnabled = false
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if index < puzzle.count {
            return puzzle[index].unresolvedImages.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let image = UIImageView(image: UIImage(named: puzzle[index].unresolvedImages[indexPath.item])!)
        cell.contentView.addSubview(image)
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4).isActive = true
        image.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant:4).isActive = true
        image.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 4).isActive = true
        image.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 4).isActive = true
        image.backgroundColor = .white

        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(checkGameState)))
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkGameState)))
        return cell
    }
    
}

extension ViewCollectionController : UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
               return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: collectionView.frame.width/2-10, height: (collectionView.frame.height - 8 )/3)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
    
}

extension ViewCollectionController  : UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
          let item = self.puzzle[index].unresolvedImages[indexPath.item]
          let itemProvider = NSItemProvider(object: item as NSString)
          let dragItem = UIDragItem(itemProvider: itemProvider)
          dragItem.localObject = dragItem
          return [dragItem]
      }
}

extension ViewCollectionController : UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
           if puzzle[index].unresolvedImages == puzzle[index].resultImages {
            clearTimer()
            Alert.showSolvedPuzzleAlert(on: self)
            collectionView.dragInteractionEnabled = false
               if index == puzzle.count - 1 {
                   navigationItem.rightBarButtonItem?.isEnabled = false
               } else {
                   navigationItem.rightBarButtonItem?.isEnabled = true
               }
           }
       }
       
       func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
         if collectionView.hasActiveDrag {
               return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
           }
           return UICollectionViewDropProposal(operation: .forbidden)
       }
       
       func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
           
           var destinationIndexPath: IndexPath
           if let indexPath = coordinator.destinationIndexPath {
               destinationIndexPath = indexPath
           } else {
               let row = collectionView.numberOfItems(inSection: 0)
               destinationIndexPath = IndexPath(item: row - 1, section: 0)
           }
           
           if coordinator.proposal.operation == .move {
               self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
           }
       }
       
       fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath:IndexPath, collectionView: UICollectionView) {
           
           if let item = coordinator.items.first,
               let sourceIndexPath = item.sourceIndexPath {
               
               collectionView.performBatchUpdates({
                   puzzle[index].unresolvedImages.swapAt(sourceIndexPath.item, destinationIndexPath.item)
                collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
               }, completion: nil)
               
               coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
           }
       }
    
}
