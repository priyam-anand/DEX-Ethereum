import React, { useState } from 'react'
import "./Navbar.css";
import eth from "../../assets/eth.png";

const Navbar = () => {

    const [show, setShow] = useState(false);

    return (
        <div className='navbar-wrapper'>
            <div className="navbar-tab-1">
                <div className="pill nav-active">
                    Swap
                </div>
                <div className="pill">
                    Pool
                </div>
            </div>
            <div className='navbar-right-wrapper'>
                <div className='navbar-hover-dropdown'>
                    <div className="navbar-tab-2" onMouseOver={e => setShow(true)} onMouseOut={e => setShow(false)}>
                        <img src={eth} alt="eth" />
                        <span>
                            Ethereum
                        </span>
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ><polyline points="6 9 12 15 18 9"></polyline></svg>
                    </div>
                    {
                        show ? <div className="navbar-dropdown" onMouseOver={e => setShow(true)} onMouseOut={e => setShow(false)}>
                            <span className="navbar-dropdown-header">
                                Select a network
                            </span>
                            <span class="navbar-network nav-active">
                                <img src={eth} alt="eth" />
                                Ethereuem
                            </span>
                            <span className='navbar-network'>
                                <img src="https://c8.alamy.com/zooms/9/97bc479bb078411086563a98514de08d/2gy0efw.jpg" alt="tez" />
                                Tezos
                            </span>
                        </div> : <></>
                    }

                </div>

                <div className="navbar-tab-3">
                    <div className="navbar-bal">
                        0 ETH
                    </div>
                    <div className="navbar-account">
                        0x2860...127e
                    </div>
                </div>
            </div>

        </div>
    )
}

export default Navbar