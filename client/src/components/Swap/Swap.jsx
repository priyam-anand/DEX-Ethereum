import React, { useState } from 'react'
import "./Swap.css";
import eth from "../../assets/eth.png";
import { Button, Modal } from 'react-bootstrap';

const Swap = () => {

    const [show, setShow] = useState(false);

    const handleClose = () => setShow(false);
    const handleShow = () => setShow(true);

    return (
        <main className='main-wrapper'>
            <div className="swap-header">
                <div className="swap-row">
                    Swap
                </div>
            </div>
            <div className="swap-body-outer-wrapper">
                <div className="swap-body-inner-wrapper">
                    <div>
                        <div className="swap-input-wrapper">
                            <div className="swap-input">
                                <div className="swap-input-panel">
                                    <input type="text" placeholder='0.0' />
                                    <button className="swap-input-btn" onClick={handleShow}>
                                        <span>
                                            <img src={eth} alt="eth" />
                                            ETH
                                            <svg width="12" height="7" viewBox="0 0 12 7" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.97168 1L6.20532 6L11.439 1" stroke="#AEAEAE"></path></svg>
                                        </span>
                                    </button>
                                </div>
                                <div className="swap-input-balance-wrapper">
                                    Balance : 0.0
                                </div>
                            </div>
                        </div>

                        <div className="swap-down-arrow">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8F96AC" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><polyline points="19 12 12 19 5 12"></polyline></svg>
                        </div>

                        <div className="swap-input-wrapper">
                            <div className="swap-input">
                                <div className="swap-input-panel">
                                    <input type="text" placeholder='0.0' />
                                    <button className="swap-input-btn">
                                        <span>
                                            <img src={eth} alt="eth" />
                                            ETH
                                            <svg width="12" height="7" viewBox="0 0 12 7" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.97168 1L6.20532 6L11.439 1" stroke="#AEAEAE"></path></svg>
                                        </span>
                                    </button>
                                </div>
                                <div className="swap-input-balance-wrapper">
                                    Balance : 0.0
                                </div>
                            </div>
                        </div>

                        <div className="exchage-rate-wrapper">
                            1 UNI = 0.04 ETH
                        </div>

                        <button className="swap-btn">
                            Swap
                        </button>

                    </div>
                </div>
            </div>
            <Modal
                show={show}
                onHide={handleClose}
                backdrop="static"
                keyboard={false}
                centered
                aria-labelledby="contained-modal-title-vcenter"
            >
                <Modal.Body>
                    <div className="swap-modal-header">
                        Select a token
                    </div>
                    <hr />
                    <div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div>
                    <div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div><div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div><div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div><div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div><div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div><div className="token-wrapper">
                        <img src={eth} alt="" />
                        ETH
                        <span>
                            (Ether)
                        </span>
                    </div>
                </Modal.Body>
                <button className='token-modal-close' onClick={handleClose}>
                    Close
                </button>
            </Modal>
        </main>
    )
}

export default Swap